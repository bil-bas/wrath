module Chingu
  class GameState
    MAX_FRAME_TIME = 100 # Milliseconds cap on frame calculations.

    def setup
      on_input(:f12) { pry } if respond_to? :pry
    end

    # Milliseconds since the last frame, but capped, so we don't break physics.
    def frame_time
      [$window.dt, MAX_FRAME_TIME].min
    end
  end
end