function dbus_connection_close(conn)
    ccall((:dbus_connection_close, libdbus), Cvoid, (Ptr{DBusConnection},), conn)
end
function dbus_connection_flush(conn)
    ccall((:dbus_connection_flush, libdbus), Cvoid, (Ptr{DBusConnection},), conn)
end
function dbus_connection_send_with_reply(conn, msg, pending, timeout)
    ccall((:dbus_connection_send_with_reply, libdbus),
          Bool,
          (Ptr{DBusConnection}, Ptr{DBusMessage}, Ptr{Ptr{DBusPendingCall}}, Cint),
          conn, msg, pending, timeout)
end
