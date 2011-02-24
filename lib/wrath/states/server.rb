# encoding: utf-8

class Server < GameStates::NetworkServer
  trait :timer

  attr_reader :remote_socket

  def initialize(options = {})
    options = {
      address: "0.0.0.0",
      port: 7778,
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
    puts "* Player connected: #{socket.inspect}"

    @remote_socket = socket
  end

  def on_disconnect(socket)
    puts "* Player disconnected: #{socket.inspect}"
  end

  def draw
    @font.draw("Waiting for client...", 0, 0, ZOrder::GUI)
  end

  def on_msg(socket, message)
    case message[:type]
      when :ready
        puts "Client is ready"
        push_game_state Play.new(:server)

      else
        raise "Unrecognised message: #{message.inspect}"
    end
  end

  def update
    if current_game_state.is_a? Play
      current_game_state.objects.each {|o| broadcast_msg(type: :status, id: o.id, status: o.status) }
    end

    super
  end
end