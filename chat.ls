
require! {
  EventEmitter: eventemitter2\EventEmitter2
}

class ChatMessage extends EventEmitter
  dispatch-message: !(command, ...args) ->
    @emit command, args


class ChatMessageHandler
  ~>  # make this class no need 'new' to create an instance

  onTOPIC: !(arg1, arg2, arg3, arg4) ->

  onMSG: !(arg1, arg2, arg3, arg4) ->

  onPRIVMSG: !(arg1, arg2, arg3, arg4) ->

  onJOIN: !(arg1, arg2, arg3, arg4) ->

  onPART: !(arg1, arg2, arg3, arg4) ->

  register: !(ev) ->
    ev.on \TOPIC, @onTOPIC
    ev.on \MSG, @onMSG
    ev.on \PRIVMSG, @onPRIVMSG
    ev.on \JOIN, @onJOIN
    ev.on \PART, @onPART

  unregister: !(ev) ->
    ev.off \TOPIC, @onTOPIC
    ev.off \MSG, @onMSG
    ev.off \PRIVMSG, @onPRIVMSG
    ev.off \JOIN, @onJOIN
    ev.off \PART, @onPART


let chat = new ChatMessage!
  console.log chat.on
  console.log chat.on-message

  handler = ChatMessageHandler()
  chat.on \TOPIC, handler.onTOPIC
  chat.emit \TOPIC, 1, 2, 3, 4
