module DBus

export connect, request_name!

using Dbus_jll

include("api.jl")

const ERROR = Ref{DBusError}()

struct DBusException
    title::String
    name::Cstring
    msg::Cstring
end
function Base.show(io::IO, ex::DBusException)
    name = Base.unsafe_string(ex.name)
    msg = Base.unsafe_string(ex.msg)
    print(io, ex.title, " (", name, "): ", msg)
end

function check(title, error=ERROR)
    if dbus_error_is_set(error)
        name = error[].name
        msg = error[].message
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
    check("Name Request")
    if strict && (ret != DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER ||
                  ret != DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER)
        error("request_name! failed: $ret")
    end
    ret
end

function __init__()
    dbus_error_init(ERROR)
end

end # module
