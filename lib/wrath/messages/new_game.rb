module Wrath
class Message
  # Sent by the server to leave the lobby and start a new game.
  class NewGame < Message
    protected
    def action(state)
      state.push_game_state Play.new(state.network)
    end
  end
end
end