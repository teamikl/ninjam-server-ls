
require! {
  assert
  crypto
  SmartBuffer: 'smart-buffer'
}

{max, min} = require 'prelude-ls'

# NOTE: struct and field naming follows mpb.h

const PROTO_VER_MIN = 0x00020000
const PROTO_VER_MAX = 0x0002FFFF
const PROTO_VER_CUR = 0x00020000

const SERVER_AUTH_CHALLENGE = 0x00
const SERVER_AUTH_REPLY = 0x01
const SERVER_CONFIG_CHANGE_NOTIFY = 0x02
const SERVER_USERINFO_CHANGE_NOTIFY = 0x03
const SERVER_DOWNLOAD_INTERVAL_BEGIN = 0x04
const SERVER_DOWNLOAD_INTERVAL_WRITE = 0x05
const CLIENT_AUTH_USER = 0x80
const CLIENT_SET_USERMASK = 0x81
const CLIENT_SET_CHANNEL = 0x82
const CLIENT_UPLOAD_INTERVAL_BEGIN = 0x83
const CLIENT_UPLOAD_INTERVAL_WRITE = 0x84
const CHAT_MESSAGE = 0xC0
const KEEP_ALIVE = 0xFD
const EXTENDED = 0xFE
const INVALID = 0xFF

const KeepAlivePacket = new Buffer("FD00000000", "hex").toString()

# keep-alive range is in range 0 to 255 (8 bits)
verify-keep-alive = (min 255) . (max 0)


# NOTE: read from stream may raise RangeError

function parse-auth-challenge (stream)
  # XXX: encoding of license text
  do
    challenge: stream.readBuffer 8  # length: 8
    server-caps: stream.readUInt32LE!
    protocol-version: stream.readUInt32LE!
    license-agreement: stream.readStringNT!  # NULL char is stripped


function parse-auth-reply (stream)
  do
    flag: stream.readUInt8!
    error-message: stream.readStringNT!
    max-channels: stream.readUInt8!


function parse-config-change-notify (stream)
  do
    bpm: stream.readUInt16LE!
    bpi: stream.readUInt16LE!


# TODO: how to make async interface?
# see core library which provide sync/async function
# and they can be functor.

function parse-userinfo-change-notify (stream, callback)
  do
    callback parse-userinfo-change-notify-iter stream
  while stream.length < stream._read-offset


function parse-userinfo-change-notify-sync (stream)
  result = []
  parse-userinfo-change-notify stream, result.push
  result


function parse-userinfo-change-notify-iter (stream)
  do
    active: stream.readUInt8!
    channel-index: stream.readUInt8!
    volume: stream.readUInt16LE!
    pan: stream.readInt8! # [-128 to 127]
    username: stream.readStringNT!
    channel-name: stream.readStringNT!


function build-auth-challenge (challenge, server-caps, protocol-version, license-agreement)
  has-license = license-agreement is not ""

  # NOTE: server-caps layout UInt32LE, so each byte are
  #  keep-alive (0 to 255)
  #  has-license (0 or 1)
  #  reserved1 (0x00)
  #  reserved2 (0x00)

  # They are ugly bitwise op symbols in LiveScript.
  # Please, read translated JavaScript code, you will know.
  #
  # (A) use JavaScript literal `` JS code here `` -> can't check by lint.
  # (B) separate 32 bit to 4 bytes little endian.
  # (C) write in JS separate module.
  if has-license
    server-caps .|.= 2~0001  # set the lowest bit 1
  else
    server-caps .&.= ~1  # else set 0

  writer = new SmartBuffer!
    ..writeBuffer challenge, 0  # offset: 0
    ..writeUInt32LE server-caps
    ..writeUInt32LE protocol-version
    ..writeStringNT license-agreement if has-license
  writer.to-buffer!


function build-auth-user (pass-hash, username, anonymous, client-caps, protocol-version)
  writer = new SmartBuffer!
    ..writeBuffer pass-hash, 0 # offset: 0
    ..writeString "anonymous:" if anonymous
    ..writeStringNT username
    ..writeUInt32LE client-caps
    ..writeUInt32LE protocol-version
  writer.to-buffer!


function parse-auth-user (stream)
  do
    password-hash: stream.readBuffer 20 # length: 20
    username: stream.readStringNT!
    capabilities: stream.readUInt32LE!
    version: stream.readUInt32LE!


function parse-chat-message (stream)
  do
    command: stream.readStringNT!
    arg1: stream.readStringNT!
    arg2: stream.readStringNT!
    arg3: stream.readStringNT!
    arg4: stream.readStringNT!


function build-chat-message (command, arg1, arg2, arg3, arg4)
  writer = new SmartBuffer!
    ..writeStringNT command
    ..writeStringNT arg1
    ..writeStringNT arg2
    ..writeStringNT arg3
    ..writeStringNT arg4
  writer.to-buffer!


function create-auth-password-hash (challenge, username, password="", anonymous=true)
  hash1 = crypto.create-hash 'sha1'
    ..update "anonymous:" if anonymous
    ..update "#{username}:#{password}"
  hash2 = crypto.create-hash 'sha1'
    ..update hash1.digest!
    ..update challenge
  hash2.digest!


# Explit exports
module.exports = do
  parse-auth-challenge: parse-auth-challenge
  build-auth-challenge: build-auth-challenge
  parse-auth-reply: parse-auth-reply
  parse-config-change-notify: parse-config-change-notify
  parse-userinfo-change-notify: parse-userinfo-change-notify
  build-auth-user: build-auth-user
  parse-auth-user: parse-auth-user
  parse-chat-message: parse-chat-message
  build-chat-message: build-chat-message
  verify-keep-alive: verify-keep-alive
  create-auth-password-hash: create-auth-password-hash

  SERVER_AUTH_CHALLENGE: SERVER_AUTH_CHALLENGE
  SERVER_AUTH_REPLY: SERVER_AUTH_REPLY
  SERVER_CONFIG_CHANGE_NOTIFY: SERVER_CONFIG_CHANGE_NOTIFY
  SERVER_USERINFO_CHANGE_NOTIFY: SERVER_USERINFO_CHANGE_NOTIFY
  SERVER_DOWNLOAD_INTERVAL_BEGIN: SERVER_DOWNLOAD_INTERVAL_BEGIN
  SERVER_DOWNLOAD_INTERVAL_WRITE: SERVER_DOWNLOAD_INTERVAL_WRITE
  CLIENT_AUTH_USER: CLIENT_AUTH_USER
  CLIENT_SET_USERMASK: CLIENT_SET_USERMASK
  CLIENT_SET_CHANNEL: CLIENT_SET_CHANNEL
  CLIENT_UPLOAD_INTERVAL_BEGIN: CLIENT_UPLOAD_INTERVAL_BEGIN
  CLIENT_UPLOAD_INTERVAL_WRITE: CLIENT_UPLOAD_INTERVAL_WRITE
  CHAT_MESSAGE: CHAT_MESSAGE
  KEEP_ALIVE: KEEP_ALIVE
  EXTENDED: EXTENDED
  INVALID: INVALID

