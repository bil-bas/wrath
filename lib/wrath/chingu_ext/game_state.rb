module Chingu
  class GameState
    include Wrath::Log
    extend Forwardable

    def self.t; R18n.get.t.game_state[Inflector.underscore(Inflector.demodulize(name)).to_sym]; end
    def t; self.class.t; end

    MAX_FRAME_TIME = 100 # Milliseconds cap on frame calculations.

    def_delegators :$window, :settings, :controls, :statistics, :achievement_manager, :pixel
    def_delegators :$window, :sprite_scale, :width, :height
    def_delegators :@game_state_manager, :pop_until_game_state

    alias_method :original_initialize, :initialize
    public
    def initialize(options = {})
      on_input(:f12) { pry } if respond_to? :pry
      original_initialize(options)
    end

    public
    # Milliseconds since the last frame, but capped, so we don't break physics.
    def frame_time
      [$window.dt, MAX_FRAME_TIME].min
    end

    public
    # Find an object, via its network ID.
    def object_by_id(id)
      game_objects.object_by_id(id)
    end

    public
    # Do we allow a specific network message to perform its action?
    def accept_message?(message); false; end
    
    public
    # Fudge to allow Fidgit::Elements to be drawn in Chingu states.
    def draw_rect(x, y, width, height, z, color, mode = :default)
      pixel.draw x, y, z, width, height, color, mode

      nil
    end
    
    public
    # Fudge to allow Fidgit::Elements to be drawn in Chingu states.
    def draw_frame(x, y, width, height, thickness, z, color, mode = :default)
      draw_rect(x - thickness, y, thickness, height, z, color, mode) # left
      draw_rect(x - thickness, y - thickness, width + thickness * 2, thickness, z, color, mode) # top (full)
      draw_rect(x + width, y, thickness, height, z, color, mode) # right
      draw_rect(x - thickness, y + height, width + thickness * 2, thickness, z, color, mode) # bottom (full)

      nil
    end
  end
end