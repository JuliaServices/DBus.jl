using DBus

title, msg = ARGS[1:2]

conn = DBus.connect()

owner = DBus.send_recv!(conn,
                        "org.freedesktop.DBus",
                        "/org/freedesktop/DBus",
                        "org.freedesktop.DBus",
                        "GetNameOwner",
                        ["org.freedesktop.Notifications"])

DBus.send_recv!(conn,
                owner,
                "/org/freedesktop/Notifications",
                "org.freedesktop.Notifications",
                "Notify",
                [
                    "notify-send",
                    UInt32(0),
                    "",
                    title,
                    msg,
                    String[],
                    Dict{String,Ref}[],
                    Int32(-1)
                ])
