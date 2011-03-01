module Chingu
  class GameState
    def setup
      on_input(:f12) { pry } if respond_to? :pry
    end
  end
end