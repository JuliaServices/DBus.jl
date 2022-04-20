function dbus_message_iter_init(msg, iter)
    ccall((:dbus_message_iter_init, libdbus),
          Bool, (Ptr{DBusMessage}, Ptr{DBusMessageIter},), msg, iter)
end
function dbus_message_iter_init_append(msg, iter)
    ccall((:dbus_message_iter_init_append, libdbus),
          Bool,
          (Ptr{DBusMessage}, Ptr{DBusMessageIter}),
          msg, iter)
end
function dbus_message_iter_get_arg_type(iter)
    Char(ccall((:dbus_message_iter_get_arg_type, libdbus),
               UInt8, (Ptr{DBusMessageIter},), iter))
end
function dbus_message_iter_get_basic(iter, T)
    ref = Ref{UInt64}()
    ccall((:dbus_message_iter_get_basic, libdbus),
          Cvoid, (Ptr{DBusMessageIter}, Ptr{UInt64}), iter, ref)
    if T === String
        return unsafe_string(Ptr{Cchar}(ref[]))
    else
        return unsafe_trunc(T, ref[])
    end
end
function dbus_message_iter_append_basic(iter, type, arg)
    ccall((:dbus_message_iter_append_basic, libdbus),
          UInt64, (Ptr{DBusMessageIter}, UInt8, Ptr{Cvoid}),
          iter, UInt8(type), arg)
end
function dbus_message_iter_open_container(iter, type, spec, inner_iter)
    ccall((:dbus_message_iter_open_container, libdbus),
          Cvoid,
          (Ptr{DBusMessageIter}, UInt8, Cstring, Ptr{DBusMessageIter}),
          iter, UInt8(type), spec, inner_iter)
end
function dbus_message_iter_close_container(iter, inner_iter)
    ccall((:dbus_message_iter_close_container, libdbus),
          Cvoid,
          (Ptr{DBusMessageIter}, Ptr{DBusMessageIter}),
          iter, inner_iter)
end

function dbus_message_new_method_call(target, object, interface, method)
    ccall((:dbus_message_new_method_call, libdbus),
          Ptr{DBusMessage},
          (Cstring, Cstring, Cstring, Cstring),
          target, object, interface, method)
end
function dbus_message_unref(msg)
    ccall((:dbus_message_unref, libdbus), Bool, (Ptr{DBusMessage},), msg)
end
function dbus_message_get_error_name(msg)
    ccall((:dbus_message_get_error_name, libdbus),
          Cstring, (Ptr{DBusMessage},), msg)
end
