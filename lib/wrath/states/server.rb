# encoding: utf-8

class Server < GameStates::NetworkServer
  trait :timer

  attr_reader :remote_socket

  def initialize(options = {})
    options = {
      address: "0.0.0.0",
      port: 7778,
    }.merge! options

    @address = options[:address]
    @port = options[:port]
    @remote_socket = nil

    @font = Font[16]

    super options

    start(@address, @port)
  end

  #
  # Called for each new client connecting to out server
  #
  def on_connect(socket)
    puts "* New player: #{socket.inspect}"

    @remote_socket = socket
    $window.push_game_state Play
  end

  def on_disconnect(socket)
  end

  def update
    super # Let NetworkServer#update do it's thing, poll incoming connections and data

    #@remote_player.socket.broadcast_msg(player_position: [@local_player.x, @local_player.y])
  end

  def draw
    @font.draw("Waiting for client...", 0, 0, ZOrder::GUI)
  end

  def restart
    puts "* Restarting game ..."
  end

  def on_msg(socket, data)
    case data[:type]
      when :position
        @remote_player.x = data[:x]
        @remote_player.y = data[:y]
    end
  end
end