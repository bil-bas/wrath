module Wrath
class Message
  # Sent by client in response to making a connection.
  class Ready < Message
    protected
    def action(state)
      log.info "Client is ready; opening the lobby"

      state.push_game_state Lobby.new(state)
    end
  end
end
end