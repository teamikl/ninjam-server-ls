
require! {
  util
  assert
  stream.Transform
  StreamParser: 'stream-parser'
  SmartBuffer: 'smart-buffer'
}

##
# NetMessageParser
#
const NET_MESSAGE_HEADER_SIZE = 5


!function NetMessageParser
  Transform.call @
  @msg-type = null
  @msg-len = 0
  @_bytes NET_MESSAGE_HEADER_SIZE, @on-header

util.inherits NetMessageParser, Transform
StreamParser NetMessageParser.prototype


NetMessageParser.prototype.on-payload = (buffer, output) !->
  assert.ok @msg-len == buffer.length
  @emit \message, @msg-type, new SmartBuffer(buffer)
  @_bytes NET_MESSAGE_HEADER_SIZE, @on-header


NetMessageParser.prototype.on-header = (buffer, output) !->
  # NetMessage header structure
  # - `type`   offset: 0 size: 1 (unsigned byte)
  # - `length` offset: 1 size: 4 (unsigned int 32 bits little endian)
  type = @msg-type = buffer.readUInt8 0
  len = @msg-len = buffer.readUInt32LE 1

  # console.log "HEADER #{type} #{len}"

  # ignore keep-alive payload
  if len > 0
    @_bytes len, @on-payload
  else
    # 0xFD keep-alive
    # @emit \message, type, null
    @_bytes NET_MESSAGE_HEADER_SIZE, @on-header


module.exports = do
  NetMessageParser
