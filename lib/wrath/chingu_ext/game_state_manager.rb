module Chingu
  class GameStateManager
    #
    # Pops through all game states until matching a given game state
    #
    def pop_until_game_state(new_state)
      if new_state.is_a? Class
        raise ArgumentError, "No state of given class is on the stack" unless @game_states.map {|s| s.class }.include? new_state

        pop_game_state until current_game_state.is_a? new_state

      else
        raise ArgumentError, "State is not on the stack" unless @game_states.include? new_state

        pop_game_state while current_game_state != new_state
      end
    end
  end
end