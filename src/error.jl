function dbus_error_init(error)
    ccall((:dbus_error_init, libdbus), Cvoid, (Ptr{DBusError},), error)
end
function dbus_error_free(error)
    ccall((:dbus_error_free, libdbus), Cvoid, (Ptr{DBusError},), error)
end
function dbus_error_is_set(error)
    ccall((:dbus_error_is_set, libdbus), Cint, (Ptr{DBusError},), error) != 0
end
