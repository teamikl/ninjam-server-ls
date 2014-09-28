#!/usr/bin/env lsc

#
# Copyright 2014 (C) Ikkei Shimomura (tea) <Ikkei.Shimomura@gmail.com>
#

require! {
  assert
  net
  events.EventEmitter
  './parser'.NetMessageParser
}

log = console.log.bind console


config = do
  host: \127.0.0.1
  port: 2050
  keep-alive: 30 # seconds
  logging:
    info: true
    debug: true

const __debug__ = config.logging.debug


!function main
  ev = new EventEmitter!

  if config.logging.info  # need logging framework
    ev.on \server-start (address) !->
      log "[INFO] server start #{address}"

    ev.on \client-connected, (address) !->
      log "[INFO] #{address} connected"

    ev.on \client-disconnected, (address) !->
      log "[INFO] #{address} disconnected"


  net.create-server (conn) !->
    address = "#{conn.remote-address}:#{conn.remote-port}"
    parser = new NetMessageParser!

    parser.on \message, (msg-type, buffer) !->
      console.log "on message #{msg-type}"

    ev.emit \client-connected, address

    conn.on \end, !->
      ev.emit \client-disconnected, address

    conn.pipe parser

    # TODO: pipe to payload parser

  .on \error, !(error) ->
    log "[ERROR] #{error}"

  .listen config.port, !->
    ev.emit \server-start, "#{config.host}:#{config.port}"


main! unless module.parent
