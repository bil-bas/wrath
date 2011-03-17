module Wrath
class Client < GameStates::NetworkClient
  trait :timer

  public
  def accept_message?(message); [Message::ServerReady].find {|m| message.is_a? m }; end

  def initialize(options = {})
    options = {
    }.merge! options

    @font = Font[16]

    super options

    on_input(:escape) { close; pop_game_state }

    after(1) { connect(options[:address], options[:port]) }
  end

  def on_connect
    log.info "Connected to server"

    # Since we connected, accept the address/port used for future use.
    settings[:network, :address] = address
    settings[:network, :port] = port
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