module Wrath
class Client < GameStates::NetworkClient
  trait :timer

  def initialize(options = {})
    options = {
      address: "127.0.0.1",
      port: Server::DEFAULT_PORT,
    }.merge! options

    @font = Font[16]

    super options

    on_input(:escape) { close; pop_game_state }

    after(1) { connect(options[:address], options[:port]) }
  end

  def on_connect
    log.info "Connected to server"
    send_msg(Message::Ready.new)
    push_game_state Lobby.new(self)
  end

  def on_disconnect
    log.info "Disconnected from server"
    game_state_manager.pop_until_game_state Menu
  end

  def draw
    @font.draw("Connecting to host...", 0, 0, ZOrder::GUI)
  end

  def on_msg(message)
    message.process
  end
end
end