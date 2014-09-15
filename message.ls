
require!{
  SmartBuffer: 'smart-buffer'
}
global import all require \prelude-ls

# NOTE: struct and field naming follows mpb.h

const PROTO_VER_MIN = 0x00020000
const PROTO_VER_MAX = 0x0002FFFF
const PROTO_VER_CUR = 0x00020000

const SERVER_AUTH_CHALLENGE = 0x00
const CLIENT_AUTH_REPLY = 0x80


function parse-auth-challenge (payload)
  # XXX: encoding of license text
  reader = new SmartBuffer payload
  do
    challenge: reader.readBuffer 8  # length: 8
    server-caps: reader.readUInt32LE 4
    protocol-version: reader.readUInt32LE 4
    license-agreement: reader.readStringNT!  # NULL char is stripped


# keep-alive range is in range 0 to 255 (8 bits)
verify-keep-alive = (min 255) . (max 0)


function build-auth-challenge (challenge, server-caps, protocol-version, license-agreement)
  has-license = license-agreement is not ""

  # NOTE: server-caps layout UInt32LE, so each byte are
  #  keep-alive (0 to 255)
  #  has-license (0 or 1)
  #  reserved1 (0x00)
  #  reserved2 (0x00)

  # They are ugly bitwise op symbols in LiveScript.
  # Please, read translated JavaScript code, you will know.
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


# Explit exports
module.exports = do
  version: \0.0.1
  parse-auth-challenge: parse-auth-challenge
  build-auth-challenge: build-auth-challenge
  verify-keep-alive: verify-keep-alive
