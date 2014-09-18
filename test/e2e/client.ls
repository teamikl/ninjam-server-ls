
require! {
  assert
  net
  crypto
  events.EventEmitter
  NetMessageParser: '../../parser'
}

global import all require '../../message'

log = console.log.bind console


!function main
  config = do
    host: \localhost
    port: 2049
    username: \anon
    password: ""
    anonymous: true

  client = new EventEmitter!
  parser = new NetMessageParser!
  socket = net.create-connection config.port, config.host
    ..on \connect, !->
      log "connected to server #{config.host}:#{config.port}"
      header = new Buffer(5)

      send-packet = !(msg-type, payload) ->
        header
          ..fill 0
          ..writeUInt8 msg-type, 0 # offset
          ..writeUInt32LE payload.length, 1 # offset
        socket
          ..write header
          ..write payload

      client.on \auth-challenge, !(auth) ->
        log "AUTH CHALLENGE"
        {username, password, anonymous} = config
        {challenge, protocol-version} = auth
        client-caps = 1 # agree license
        pass-hash = create-auth-password-hash challenge, username, password, anonymous
        assert.ok pass-hash.length == 20
        assert.ok protocol-version == 16~00020000

        send-packet do
          0x80
          build-auth-user(pass-hash, username, anonymous, client-caps, protocol-version)

      client.on \auth-reply, !(reply) ->
        log "AUTH REPLY"
        log reply

      client.on \config-change-notify, !(config) ->
        log "CONFIG CHANGE NOTIFY"
        log config

      client.on \chat-message, !(msg) ->
        log "CHAT MESSAGE"
        log msg

      client.on \unknown, !(msg-type, stream) ->
        log "UNKNOWN #{msg-type}"


      # TODO: message dispatch
      parser.on \message, !(msg-type, stream) ->
        switch msg-type
        | SERVER_AUTH_CHALLENGE =>
          client.emit \auth-challenge, parse-auth-challenge stream
        | SERVER_AUTH_REPLY =>
          client.emit \auth-reply, parse-auth-reply stream
        | SERVER_CONFIG_CHANGE_NOTIFY =>
          client.emit \config-change-notify, parse-config-change-notify stream
        | CHAT_MESSAGE =>
          client.emit \chat-message, parse-chat-message stream
        | otherwise
          client.emit \unknown, msg-type, stream

      # socket.write (new Buffer("fd00000000", "hex"))

      socket
        .pipe parser

      # TODO: .pipe socket

    ..on \end, !->
      log "end"


main! unless module.parent
