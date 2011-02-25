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

  def pre_update
    handle_incoming_data
  end

  def post_update
  end

  def on_connect
    puts "Connected to server"
    push_game_state Play.new(self)
    send_msg(Message::Ready.new)
  end

  def on_disconnect
    puts "* Disconnected from server"
  end

  def draw
    @font.draw("Connecting...", 0, 0, ZOrder::GUI)
  end

  def send_msg(message)
    data = message.to_json
    super(data)
  end

  def on_msg(message)
    JSON.parse(message).process
  end
end