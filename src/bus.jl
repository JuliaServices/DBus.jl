function dbus_bus_get(bus_type::DBusBusType, error)
    ccall((:dbus_bus_get, libdbus), Ptr{DBusConnection}, (DBusBusType, Ptr{DBusError},), bus_type, error)
end
function dbus_bus_request_name(conn, name, flag, error)
    ccall((:dbus_bus_request_name, libdbus),
          DBusRequestNameReplyFlag,
          (Ptr{DBusConnection}, Cstring, DBusNameFlag, Ptr{DBusError}),
          conn, name, flag, error)
end
function dbus_bus_release_name(conn, name, error)
    ccall((:dbus_bus_release_name, libdbus),
          DBusReleaseNameReplyFlag,
          (Ptr{DBusConnection}, Cstring, Ptr{DBusError}),
          conn, name, error)
end
function dbus_bus_name_has_owner(conn, name, error)
    ccall((:dbus_bus_name_has_owner, libdbus),
          Bool,
          (Ptr{DBusConnection}, Cstring, Ptr{DBusError}),
          conn, name, error)
end
function dbus_bus_start_service_by_name(conn, name, flags, reply, error)
    ccall((:dbus_bus_start_service_by_name, libdbus),
          Bool,
          (Ptr{DBusConnection}, Cstring, UInt32,
           Ptr{DBusStartServiceByNameReplyFlag}, Ptr{DBusError}),
          conn, name, flags, reply, error)
end
