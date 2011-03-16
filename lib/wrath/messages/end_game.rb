module Wrath
  class Message
    # Sent when either player quits the game.
    class EndGame < Message
      protected
      def action(state)
        state.game_state_manager.pop_until_game_state Lobby
      end
    end
  end
end