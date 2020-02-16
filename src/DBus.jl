module DBus

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

function connect()
    conn = dbus_bus_get(DBUS_BUS_SESSION, ERROR)
    check("Connection Error")
    @assert conn != C_NULL
    conn
end

function __init__()
    dbus_error_init(ERROR)
end

end # module
