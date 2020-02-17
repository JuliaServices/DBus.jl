struct DBusError
    name::Cstring
    message::Cstring

    dummy1::Cuint
    dummy2::Cuint
    dummy3::Cuint
    dummy4::Cuint
    dummy5::Cuint

    padding::Ptr{Cvoid}
end

function dbus_error_init(error)
    ccall((:dbus_error_init, libdbus), Cvoid, (Ptr{DBusError},), error)
end
function dbus_error_free(error)
    ccall((:dbus_error_free, libdbus), Cvoid, (Ptr{DBusError},), error)
end
function dbus_error_is_set(error)
    ccall((:dbus_error_is_set, libdbus), Cint, (Ptr{DBusError},), error) != 0
end

const DBusConnection = Cvoid
@enum DBusBusType begin
    DBUS_BUS_SESSION = Cint(0)
    DBUS_BUS_SYSTEM = Cint(1)
    DBUS_BUS_STARTER = Cint(2)
end
@enum DBusNameFlag begin
    DBUS_NAME_FLAG_ALLOW_REPLACEMENT = Cuint(1)
    DBUS_NAME_FLAG_REPLACE_EXISTING = Cuint(2)
    DBUS_NAME_FLAG_DO_NOT_QUEUE = Cuint(4)
end
@enum DBusRequestNameReplyFlag begin
    DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER = Cuint(1)
    DBUS_REQUEST_NAME_REPLY_IN_QUEUE = Cuint(2)
    DBUS_REQUEST_NAME_REPLY_EXISTS = Cuint(3)
    DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER = Cuint(4)
end

function dbus_bus_get(bus_type::DBusBusType, error)
    ccall((:dbus_bus_get, libdbus), Ptr{DBusConnection}, (DBusBusType, Ptr{DBusError},), bus_type, error)
end
function dbus_connection_close(conn)
    ccall((:dbus_connection_close, libdbus), Cvoid, (Ptr{DBusConnection},), conn)
end
function dbus_bus_request_name(conn, name, flag, error)
    ccall((:dbus_bus_request_name, libdbus),
          DBusRequestNameReplyFlag,
          (Ptr{DBusConnection}, Cstring, DBusNameFlag, Ptr{DBusError}),
          conn, name, flag, error)
end
