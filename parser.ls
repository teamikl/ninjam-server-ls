
require! {
  util
  stream.Transform
  StreamParser: 'stream-parser'
  # SmartStream: 'smart-stream'
  # EventStream: 'event-stream'
}

##
# NetMessageParser
#
const NET_MESSAGE_HEADER_SIZE = 5


!function NetMessageParser
  Transform.call @
  @._bytes NET_MESSAGE_HEADER_SIZE, @.on-header

util.inherits NetMessageParser, Transform
StreamParser NetMessageParser.prototype


NetMessageParser.prototype.on-header = (buffer, output) !->
  # NetMessage header structure
  # - `type`   offset: 0 size: 1 (unsigned byte)
  # - `length` offset: 1 size: 4 (unsigned int 32 bits little endian)
  type = buffer.readUInt8 0
  len = buffer.readUInt32LE 1

  if __debug__
    console.log buffer

  # ignore keep-alive payload
  if len > 0
    @._passthrough len
  else
    @._bytes NET_MESSAGE_HEADER_SIZE, @.on-header


module.exports = do
  NetMessageParser
