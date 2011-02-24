class Client < GameStates::NetworkClient
  trait :timer

  def initialize(options = {})
    options = {
      ip: "127.0.0.1",
      port: 7778,
    }.merge! options

    @font = Font[16]

    super options

    on_input(:escape) { disconnect; pop_game_state }

    after(0.1) { connect(options[:ip], options[:port]) }
  end

  def on_connect
    puts "Connected to server"
    push_game_state Play.new(:client)
    send_msg(type: :ready)
  end

  def on_disconnect
    puts "* Disconnected from server"
  end

  def draw
    @font.draw("Connecting...", 0, 0, ZOrder::GUI)
  end

  def on_msg(message)
    case message[:type]
      # Create an object on the client to mirror one here.
      when :create
        object = Kernel::const_get(message[:class]).create(message[:options])
        current_game_state.objects.push object
        puts "Created a #{message[:class]}"

      # Update the status (position, velocity, etc) of an object.
      when :status
        status = message[:status]
        object = current_game_state.objects.find {|o| o.id == message[:id] }
        object.update_status(status)

      else
        raise "Unrecognised message: #{message.inspect}"
    end
  end
end