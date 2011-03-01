class Client < GameStates::NetworkClient

  trait :timer

  def initialize(options = {})
    options = {
      address: "127.0.0.1",
      port: Server::DEFAULT_PORT,
    }.merge! options

    @last_sync = 0

    @font = Font[16]

    super options

    on_input(:escape) { disconnect; pop_game_state }

    after(0.1) { connect(options[:address], options[:port]) }
  end

  def pre_update
    handle_incoming_data
  end

  def post_update
    handle_outgoing_data
  end

  def on_connect
    puts "Connected to server"
    send_msg(Message::Ready.new)
  end

  def on_disconnect
    puts "* Disconnected from server"
  end

  def draw
    @font.draw("Connecting...", 0, 0, ZOrder::GUI)
  end

  def on_msg(message)
    Message.const_get(message[:type]).new(message[:values]).process
  end

  def handle_outgoing_data
    if current_game_state.is_a? Play
      if (milliseconds - @last_sync) > Server::SYNC_DELAY
        updates = 0
        current_game_state.objects.each do |object|
          if object.local? # and object.needs_sync?
            updates += 1
            send_msg(Message::Sync.new(object.sync_data))
          end
        end

        puts "Sent updates for #{updates} objects"

        @last_sync = milliseconds
      end
    end
  end
end