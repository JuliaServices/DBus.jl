function dbus_pending_call_block(pending)
    ccall((:dbus_pending_call_block, libdbus),
          Cvoid, (Ptr{DBusPendingCall},), pending)
end
function dbus_pending_call_unref(pending)
    ccall((:dbus_pending_call_unref, libdbus),
          Cvoid, (Ptr{DBusPendingCall},), pending)
end
function dbus_pending_call_steal_reply(pending)
    ccall((:dbus_pending_call_steal_reply, libdbus),
          Ptr{DBusMessage}, (Ptr{DBusPendingCall},), pending)
end
