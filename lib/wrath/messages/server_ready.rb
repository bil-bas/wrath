module Wrath
class Message
  # Sent by host to client in response to making a connection.
  class ServerReady < Message

    public
    def initialize(name)
      @name = name
    end

    protected
    def action(state)
      log.info "Server is ready; opening the lobby"

      state.push_game_state Lobby.new(state, @name)
    end
  end
end
end