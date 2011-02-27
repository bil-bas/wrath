class Message
  # Sent by the server to clear the game.
  class Start < Message
    def process
      state = $window.current_game_state
      if state.is_a? Client
        # Start
        $window.push_game_state Play.new(state)
      else
        # Restart.
        $window.switch_game_state Play.new($window.current_game_state.network)
      end

      puts "Game restarted"
    end
  end
end