module DBus

export connect, request_name!

using Dbus_jll

include("types.jl")
include("error.jl")
include("connection.jl")
include("bus.jl")
include("message.jl")
include("pending-call.jl")

const ERROR = Ref{DBusError}()

struct DBusException
    title::String
    name::String
    msg::String
end
function Base.show(io::IO, ex::DBusException)
    print(io, ex.title, " (", ex.name, "): ", ex.msg)
end

function check(title, error=ERROR)
    if dbus_error_is_set(error)
        name = Base.unsafe_string(error[].name)
        msg = Base.unsafe_string(error[].message)
        dbus_error_free(error)
        throw(DBusException(title, name, msg))
    end
end

function connect(; err=ERROR)
    conn = dbus_bus_get(DBUS_BUS_SESSION, err)
    check("Connection Opening")
    @assert conn != C_NULL
    conn
end
function connection_close!(conn; err=ERROR)
    dbus_connection_close(conn)
    check("Connection Closing")
end

function request_name!(conn, name; err=ERROR, strict=false)
    ret = dbus_bus_request_name(conn, name, DBUS_NAME_FLAG_REPLACE_EXISTING,
                                err)
    check("bus_name_request")
    if strict && (ret != DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER ||
                  ret != DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER)
        error("request_name! failed: $ret")
    end
    return ret
end
function release_name!(conn, name; err=ERROR, strict=false)
    ret = dbus_bus_release_name(conn, name, err)
    check("bus_name_release")
    if strict && ret != DBUS_RELEASE_NAME_REPLY_RELEASED
        error("release_name! failed: $ret")
    end
    return ret
end
function name_has_owner(conn, name; err=ERROR)
    ret = dbus_bus_name_has_owner(conn, name, err)
    check("bus_name_has_owner")
    return ret
end
function start_service!(conn, name; err=ERROR)
    reply = Ref{DBusStartServiceByNameReplyFlag}()
    ret = dbus_bus_start_service_by_name(conn, name, 0, reply, err)
    check("dbus_bus_start_service_by_name")
    return (;success=ret, reply=reply[])
end

dbus_type(x) = error("Invalid DBus type: $x")
const TYPE_MAP = [
    Array => DBUS_TYPE_ARRAY,
    Bool => DBUS_TYPE_BOOLEAN,
    Union{Int8,UInt8} => DBUS_TYPE_BYTE,
    Int16 => DBUS_TYPE_INT16,
    UInt16 => DBUS_TYPE_UINT16,
    Int32 => DBUS_TYPE_INT32,
    UInt32 => DBUS_TYPE_UINT32,
    Int64 => DBUS_TYPE_INT64,
    UInt64 => DBUS_TYPE_UINT64,
    Float64 => DBUS_TYPE_DOUBLE,
    String => DBUS_TYPE_STRING,
    Ref => DBUS_TYPE_VARIANT,
]
for (jltype, dbustype) in TYPE_MAP
    @eval dbus_type(::Type{$jltype}) = $dbustype
end
function julia_type(x::Char)
    for (jltype, dbustype) in TYPE_MAP
        if dbustype == x
            return jltype
        end
    end
    error("Unknown Julia type for DBus type $x")
end
dbus_spec(::Type{Vector{T}}) where T = "a$(dbus_spec(T))"
dbus_spec(::Type{Dict{K,V}}) where {K,V} = "{$(dbus_spec(K))$(dbus_spec(V))}"
dbus_spec(::Type{T}) where T = string(dbus_type(T))
dbus_spec(x) = dbus_spec(typeof(x))

function message_write!(msg, args)
    iter = Ref{DBusMessageIter}()
    dbus_message_iter_init_append(msg, iter)
    for arg in args
        message_iter_write!(iter, arg)
    end
end
function message_iter_write!(iter, arr::Vector{T}) where T
    arr_iter = Ref{DBusMessageIter}()
    dbus_message_iter_open_container(iter, DBUS_TYPE_ARRAY, dbus_spec(T), arr_iter)
    for arg in arr
        message_iter_write!(arr_iter, arg)
    end
    dbus_message_iter_close_container(iter, arr_iter)
end
function message_iter_write!(iter, arg::String)
    GC.@preserve arg begin
        arg_ptr = Ref{Cstring}(pointer(arg))
        dbus_message_iter_append_basic(iter, DBUS_TYPE_STRING, arg_ptr)
    end
end
message_iter_write!(iter, arg::T) where {T<:Integer} =
    dbus_message_iter_append_basic(iter, dbus_type(T), Ref(arg))

function message_read(msg)
    iter = Ref{DBusMessageIter}()
    if dbus_message_iter_init(msg, iter)
        return message_iter_read(iter)
    end
end
message_iter_read(iter) =
    message_iter_read(julia_type(dbus_message_iter_get_arg_type(iter)), iter)
function message_iter_read(::Type{Vector{T}}, iter) where T
    arr_iter = Ref{DBusMessageIter}()
    dbus_message_iter_recurse(iter, arr_iter)
    values = T[]
    while dbus_message_iter_has_next(arr_iter)
        S = dbus_message_iter_get_arg_type(arr_iter)
        push!(values, message_iter_read(S, arr_iter))
        dbus_message_iter_next(arr_iter)
    end
    dbus_message_iter_next(iter)
    return values
end
message_iter_read(::Type{String}, iter) =
    dbus_message_iter_get_basic(iter, String)
message_iter_read(::Type{T}, iter) where {T<:Integer} =
    dbus_message_iter_get_basic(iter, T)

function send_recv!(conn, target, object, interface, method, args)
    pending = Ref{Ptr{DBusPendingCall}}(Ptr{DBusPendingCall}(0))

    # create a new method call and check for errors
    msg = dbus_message_new_method_call(target, object, interface, method)
    @assert msg != C_NULL "Failed to allocate new message"

    # append args
    message_write!(msg, args)

    # send message and get a handle for a reply
    if !dbus_connection_send_with_reply(conn, msg, pending, -1) # -1 is default timeout
        error("Out of Memory")
    end
    if pending[] == C_NULL
        error("Pending Call was NULL")
    end
    dbus_connection_flush(conn)

    # free message
    dbus_message_unref(msg)

    # block until we recieve a reply
    dbus_pending_call_block(pending[])

    # get the reply message
    msg = dbus_pending_call_steal_reply(pending[])
    if msg == C_NULL
        error("Reply was NULL")
    end
    # free the pending message handle
    dbus_pending_call_unref(pending[])

    # read the parameters
    ret = message_read(msg)
    err = dbus_message_get_error_name(msg)
    if err != C_NULL
        err = Base.unsafe_string(err)
    end

    # free reply and close connection
    dbus_message_unref(msg)

    if err isa String
        error(err * ": " * ret)
    end
    return ret
end

function __init__()
    dbus_error_init(ERROR)
end

end # module
