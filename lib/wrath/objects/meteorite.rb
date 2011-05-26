module Wrath
  class Meteorite < Rock
    IRRADIATED_DURATION = 6000
    
    def can_be_picked_up?(container); false; end
    def ground_level; -2; end
    def casts_shadow?; false; end
    
    def initialize(options = {})
      options = {
          color: Color::GREEN.dup,
          elasticity: 0,
          encumbrance: 0.8, # Can be heavy, since it also gives strength.
      }.merge! options
      
      super(options)
      
      image.outline # Force creation of an outline image.
    end

    
    def on_stopped 
      Sample["objects/rock_sacrifice.ogg"].play
      super
    end
    
    def draw
      super
      intensity = ((parent.retro_height - z.to_f) / parent.retro_height) - 0.75
      color = Color::GREEN.dup
      color.alpha = 100
      intensity *= (3 + Math::sin(milliseconds / 500.0))
      parent.draw_glow(x, y, color, intensity) if intensity > 0
    end
    
    def draw_self
      super 
      image.outline.draw_rot x, y + 1 - z, zorder, 0, 0.5, 1.0, factor_x, factor_y, color, :additive
    end 

    def on_collision(other)
      if not parent.client? and other.is_a? Creature
        other.apply_status(:irradiated, duration: IRRADIATED_DURATION)
      end
      
      super(other)
    end
  end
end