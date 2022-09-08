using DBus
using Test

conn = DBus.connect()
@test conn != C_NULL
DBus.request_name!(conn, "test.julia.dbus")
DBus.release_name!(conn, "test.julia.dbus")
