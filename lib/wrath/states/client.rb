module Wrath
class Client < GameStates::NetworkClient
  trait :timer

  public
  def accept_message?(message); [Message::ServerReady].find {|m| message.is_a? m }; end

  def initialize(options = {})
    options = {
    }.merge! options

    @font = Font["pixelated.ttf", 48]

    super options

    on_input(:escape) { pop_game_state }

    connect
  end

  def on_connect
    log.info "Connected to server"

    # Since we connected, accept the address/port used for future use.
    settings[:network, :address] = address
    settings[:network, :port] = port
  end

  def on_disconnect
    log.info "Disconnected from server"
    pop_until_game_state self unless current_game_state == self
    pop_game_state
  end

  def on_timeout
    log.debug "Timed out from connection"
    connect
  end

  def on_connection_refused
    log.debug "Connection was refused by server"
    super
  end

  def draw
    $window.scale(1.0 / $window.sprite_scale) do
      @font.draw("Connecting to host...", 10, 10, ZOrder::GUI)
    end
  end

  def on_msg(message)
    message.process if message.is_a? Message
  end

  def popped
    close
  end
end
end