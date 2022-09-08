function dbus_threads_init_default()
    ccall((:dbus_threads_init_default, libdbus), Bool, ())
end
