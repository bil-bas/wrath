module Wrath
class Message
  # Sent by client in response to ServerReady.
  class ClientReady < Message

    public
    def initialize(name)
      @name = name
    end

    protected
    def action(state)
      log.info "Client is ready; opening the lobby"

      state.push_game_state Lobby.new(state, @name)
    end
  end
end
end