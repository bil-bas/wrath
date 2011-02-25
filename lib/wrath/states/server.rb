# encoding: utf-8

class Server < GameStates::NetworkServer
  SYNC_DELAY = 1.0 / 15.0 # 1 fps

  trait :timer

  attr_reader :remote_socket

  def initialize(options = {})
    options = {
      address: "0.0.0.0",
      port: 7778,
    }.merge! options

    @remote_socket = nil
    @last_sync = milliseconds

    @font = Font[16]

    super options

    on_input(:escape) { pop_game_state }

    start(options[:address], options[:port])
  end

  def pre_update
    handle_incoming_connections
    handle_incoming_data
  end

  def post_update
    handle_outgoing_data
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
    JSON.parse(message).process
  end

  def send_msg(socket, message)
    data = message.to_json
    super(socket, data)
  end

  def broadcast_msg(message)
    send_msg(@remote_socket, message)
  end

  def handle_outgoing_data
    if current_game_state.is_a? Play
      if (milliseconds - @last_sync) > SYNC_DELAY
        updates = 0
        current_game_state.objects.each do |object|
          if object.needs_status_update?
            updates += 1
            broadcast_msg(Message::Sync.new(object.status))
          end
        end

        puts "Sent updates for #{updates} objects"

        @last_sync = milliseconds
      end
    end

    super
  end
end