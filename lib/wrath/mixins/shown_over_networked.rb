module Wrath
  # A game-state that is shown over a networked state, that should continue to be updated (but not necessarily shown.
  # If not shown over a networked state, then do nothing.
  module ShownOverNetworked
    def setup
      super

      # Find the networked state, somewhere below us on the stack.
      state = self
      @networked_state = nil
      while state = state.previous_game_state
        if state.networked?
          @networked_state = state
          break
        end
      end
    end

    def update
      @networked_state.update if @networked_state
      super
    end
  end
end