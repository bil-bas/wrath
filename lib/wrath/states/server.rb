module Wrath
class Server < GameStates::NetworkServer
  trait :timer

  attr_reader :remote_socket

  public
  def accept_message?(message); [Message::ClientReady].find {|m| message.is_a? m }; end

  public
  def initialize(options = {})
    @remote_socket = nil

    @font = Font["pixelated.ttf", 16]

    super options

    on_input(:escape) { pop_game_state }

    start(options[:address], options[:port])

    settings[:network, :port] = port
  end

  #
  # Called for each new client connecting to our server
  #
  def on_connect(socket)
    if @remote_socket
      log.warn { "Another player tried to connect, but was refused: #{socket.inspect}" }
      disconnect_client(socket)
    else
      log.info { "Player connected: #{socket.inspect}" }
      @remote_socket = socket
      send_msg(@remote_socket, Message::ServerReady.new(settings[:player, :name]))
    end
  end

  def on_disconnect(socket)
    log.info { "Player disconnected: #{socket.inspect}" }
    pop_until_game_state Menu unless current_game_state.is_a? Menu
    @remote_socket = nil
  end

  def draw
    @font.draw("Waiting for player...", 0, 0, ZOrder::GUI)
  end

  def on_msg(socket, message)
    message.process
  end

  def broadcast_msg(message)
    send_msg(@remote_socket, message) if @remote_socket
  end
  
  def popped
    close
  end
end
end