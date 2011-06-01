module Chingu
  class GameStateManager
    #
    # Pops through all game states until matching a given game state (takes either a class or instance to match).
    #    
    def pop_until_game_state(new_state, options = {})
      if new_state.is_a? Class
        raise ArgumentError, "No state of given class is on the stack" unless @game_states[0..-2].any? {|s| s.is_a? new_state }

        pop_game_state(options) until current_game_state.is_a? new_state

      else
        raise ArgumentError, "State is not on the stack" unless @game_states[0..-2].include? new_state

        pop_game_state(options) until current_game_state == new_state
      end
    end
  
    #
    # Switch to a given game state, _replacing_ the current active one.
    # By default setup() is called on the game state  we're switching _to_.
    # .. and finalize() is called on the game state we're switching _from_.
    #   
    def switch_game_state(state, options = {})
      options = {
          :setup => true,
          :finalize => true, 
          :transitional => true,
      }.merge! options
      
      # Don't setup or finalize the underlying state, since it never becomes active.
      pop_game_state(options.merge(:setup => false))
      push_game_state(state, options.merge(:finalize => false))
    end
    alias :switch :switch_game_state
    
    #
    # Adds a state to the game state-stack and activates it.
    # By default setup() is called on the new game state 
    # .. and finalize() is called on the game state we're leaving.
    # Order of events is old.finalize (if :finalize), new.pushed, new.setup (if :setup).
    #    
    def push_game_state(state, options = {})
      options = {
        :setup => true,
        :finalize => true,
        :transitional => true,
      }.merge! options
      
      new_state = game_state_instance(state)
            
      if new_state
        
        # So BasicGameObject#create connects object to new state in its setup()
        self.inside_state = new_state
        
        # Make sure the game state knows about the manager
        # Is this doubled in GameState.initialize() ?
        new_state.game_state_manager = self
        
        # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
        current_game_state.finalize   if current_game_state.respond_to?(:finalize) && options[:finalize]
                
        # Call setup
        new_state.pushed              if new_state.respond_to?(:pushed)
        new_state.setup               if new_state.respond_to?(:setup) && options[:setup]
        
        if @transitional_game_state && options[:transitional]
          # If we have a transitional, push that instead, with new_state as first argument
          transitional_game_state = @transitional_game_state.new(new_state, @transitional_game_state_options)
          transitional_game_state.game_state_manager = self
          self.push_game_state(transitional_game_state, :transitional => false)
        else
          # Push new state on top of stack and therefore making it active
          @game_states.push(new_state)
        end
        ## MOVED: self.inside_state = current_game_state
      end
      
      self.inside_state = nil   # no longer 'inside' (as in within initialize() etc) a game state
    end
    alias :push :push_game_state
    
    #
    # Pops a state off the game state-stack, activating the previous one.
    # By default setup() is called on the game state that becomes active.
    # .. and finalize() is called on the game state we're leaving.
    # Order of events is old.finalize (if :finalize), old.popped, new.setup (if :setup).
    #    
    def pop_game_state(options = {})
      options = {
        :setup => true,
        :finalize => true,
        :transitional => true,
      }.merge! options
      
      #
      # Give the soon-to-be-disabled state a chance to clean up by calling finalize() on it.
      #
      current_game_state.finalize    if current_game_state.respond_to?(:finalize) && options[:finalize]
      current_game_state.popped      if current_game_state.respond_to?(:popped)

      #
      # Activate the game state "below" current one with a simple Array.pop
      #
      @game_states.pop
            
      # So BasicGameObject#create connects object to new state in its setup()
      # Is this doubled in GameState.initialize() ?
      self.inside_state = current_game_state
      
      # Call setup on the new current state
      current_game_state.setup       if current_game_state.respond_to?(:setup) && options[:setup]
      
      if @transitional_game_state && options[:transitional]
        # If we have a transitional, push that instead, with new_state as first argument
        transitional_game_state = @transitional_game_state.new(current_game_state, @transitional_game_state_options)
        transitional_game_state.game_state_manager = self
        self.push_game_state(transitional_game_state, :transitional => false)
      end
      
      ## MOVED: self.inside_state = current_game_state
      self.inside_state = nil   # no longer 'inside' (as in within initialize() etc) a game state
    end
    alias :pop :pop_game_state
  end  
end