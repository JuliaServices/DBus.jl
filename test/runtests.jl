using DBus
using Test

conn = DBus.connect()
@test conn != C_NULL
