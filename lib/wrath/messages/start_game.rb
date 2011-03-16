module Wrath
class Message
  # Sent by the server after new objects creation, to actually start the game.
  class StartGame < Message
    def process
      state = $window.current_game_state
      if state.is_a? Play
        state.start_game
      end
    end
  end
end
end