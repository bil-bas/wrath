module Wrath
class Message
  # Sent by the server after new objects creation, to actually start the game.
  class StartGame < Message
    protected
    def action(state)
      state.start_game
    end
  end
end
end