using DBus

conn = DBus.connect(:system)

DBus.start_service!(conn, "org.freedesktop.GeoClue2")
@assert DBus.name_has_owner(conn, "org.freedesktop.GeoClue2")

owner = DBus.send_recv!(conn,
                        "org.freedesktop.DBus",
                        "/org/freedesktop/DBus",
                        "org.freedesktop.DBus",
                        "GetNameOwner",
                        ["org.freedesktop.GeoClue2"])
@show owner

client = DBus.send_recv!(conn,
                         owner,
                         "/org/freedesktop/GeoClue2/Manager",
                         "org.freedesktop.GeoClue2.Manager",
                         "GetClient",
                         [])
@show client

for prop in ["DesktopId", "Location", "Active"]
    res = DBus.send_recv!(conn,
                          owner,
                          client,
                          "org.freedesktop.DBus.Properties",
                          "Get",
                          ["org.freedesktop.GeoClue2.Client",
                           prop])
    println("$prop = $res")
end
DBus.send_recv!(conn,
                owner,
                client,
                "org.freedesktop.DBus.Properties",
                "Set",
                ["org.freedesktop.GeoClue2.Client",
                 "DesktopId",
                 Ref("geoclue-demo-agent")])

DBus.send_recv!(conn,
                owner,
                client,
                "org.freedesktop.GeoClue2.Client",
                "Start",
                [])

@async DBus.listen_signal(conn, "org.freedesktop.GeoClue2.Client", "LocationUpdated") do msg
    ret = DBus.message_read(msg)::Vector{ObjectPath}
    loc_path = ret[2].path

    lat = DBus.send_recv!(conn,
                          owner,
                          loc_path,
                          "org.freedesktop.DBus",
                          "Get",
                          ["Latitude"])
end

readline()
