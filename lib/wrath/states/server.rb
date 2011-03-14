module Wrath
class Server < GameStates::NetworkServer
  DEFAULT_PORT = 60000

  trait :timer

  attr_reader :remote_socket

  def initialize(options = {})
    options = {
      address: "0.0.0.0",
      port: DEFAULT_PORT,
    }.merge! options

    @remote_socket = nil

    @font = Font[16]

    super options

    on_input(:escape) { pop_game_state }

    start(options[:address], options[:port])
  end

  #
  # Called for each new client connecting to our server
  #
  def on_connect(socket)
    puts "Player connected: #{socket.inspect}"
    @remote_socket = socket
  end

  def on_disconnect(socket)
    puts "Player disconnected: #{socket.inspect}"
    game_state_manager.pop_until_game_state Menu
  end

  def draw
    @font.draw("Waiting for player...", 0, 0, ZOrder::GUI)
  end

  def on_msg(socket, message)
    message.process
  end

  def broadcast_msg(message)
    send_msg(@remote_socket, message)
  end
end
end