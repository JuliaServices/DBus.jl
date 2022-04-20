struct DBusError
    name::Cstring
    message::Cstring

    dummy1::Cuint
    dummy2::Cuint
    dummy3::Cuint
    dummy4::Cuint
    dummy5::Cuint

    padding::Ptr{Cvoid}
end

const DBusConnection = Cvoid

@enum DBusBusType begin
    DBUS_BUS_SESSION = Cint(0)
    DBUS_BUS_SYSTEM = Cint(1)
    DBUS_BUS_STARTER = Cint(2)
end
@enum DBusNameFlag begin
    DBUS_NAME_FLAG_ALLOW_REPLACEMENT = Cuint(1)
    DBUS_NAME_FLAG_REPLACE_EXISTING = Cuint(2)
    DBUS_NAME_FLAG_DO_NOT_QUEUE = Cuint(4)
end
@enum DBusRequestNameReplyFlag begin
    DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER = Cuint(1)
    DBUS_REQUEST_NAME_REPLY_IN_QUEUE = Cuint(2)
    DBUS_REQUEST_NAME_REPLY_EXISTS = Cuint(3)
    DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER = Cuint(4)
end
@enum DBusReleaseNameReplyFlag begin
    DBUS_RELEASE_NAME_REPLY_RELEASED = Cuint(1)
    DBUS_RELEASE_NAME_REPLY_NON_EXISTENT = Cuint(2)
    DBUS_RELEASE_NAME_REPLY_NOT_OWNER = Cuint(3)
end
@enum DBusStartServiceByNameReplyFlag begin
    DBUS_START_REPLY_SUCCESS = Cuint(1)
    DBUS_START_REPLY_ALREADY_RUNNING = Cuint(2)
end

const DBusMessage = Cvoid
struct DBusMessageIter
  dummy1::Ptr{Cvoid}
  dummy2::Ptr{Cvoid}
  dummy3::UInt32
  dummy4::Cint
  dummy5::Cint
  dummy6::Cint
  dummy7::Cint
  dummy8::Cint
  dummy9::Cint
  dummy10::Cint
  dummy11::Cint
  pad1::Cint
  pad2::Ptr{Cvoid}
  pad3::Ptr{Cvoid}
end

const DBusPendingCall = Cvoid

const DBUS_NUMBER_OF_TYPES = 16

const DBUS_TYPE_INVALID           = Char(0)
const DBUS_TYPE_BYTE              = 'y'
const DBUS_TYPE_BOOLEAN           = 'b'
const DBUS_TYPE_INT16             = 'n'
const DBUS_TYPE_UINT16            = 'q'
const DBUS_TYPE_INT32             = 'i'
const DBUS_TYPE_UINT32            = 'u'
const DBUS_TYPE_INT64             = 'x'
const DBUS_TYPE_UINT64            = 't'
const DBUS_TYPE_DOUBLE            = 'd'
const DBUS_TYPE_STRING            = 's'
const DBUS_TYPE_OBJECT_PATH       = 'o'
const DBUS_TYPE_SIGNATURE         = 'g'
const DBUS_TYPE_UNIX_FD           = 'h'
const DBUS_TYPE_ARRAY             = 'a'
const DBUS_TYPE_VARIANT           = 'v'
const DBUS_TYPE_STRUCT            = 'r'
const DBUS_TYPE_DICT_ENTRY        = 'e'
const DBUS_STRUCT_BEGIN_CHAR      = '('
const DBUS_STRUCT_END_CHAR        = ')'
const DBUS_DICT_ENTRY_BEGIN_CHAR  = '{'
const DBUS_DICT_ENTRY_END_CHAR    = '}'
