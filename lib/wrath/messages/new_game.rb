module Wrath
class Message
  # Sent by the server to clear the game and be ready for new objects creation.
  class NewGame < Message
    def process
      state = $window.current_game_state
      case state
        when Client
          $window.push_game_state Play.new(state)

        when Play, GameOver
          $window.game_state_manager.pop_until_game_state Play
          $window.switch_game_state Play.new($window.current_game_state.network)
      end
    end
  end
end
end