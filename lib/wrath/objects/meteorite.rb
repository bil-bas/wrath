module Wrath
  class Meteorite < Rock
    IRRADIATED_DURATION = 6000

    SPRITE_FREE = 0
    SPRITE_EMBEDDED = 1
    SPRITE_FLAME = 2

    FLAME_COLOR = Color.rgba(255, 255, 255, 175)
    
    def initialize(options = {})
      options = {
          favor: 2,
          animation: "meteorite_7x7.png",
          elasticity: 0,
          encumbrance: 1.3, # Can be heavy, since it also gives strength via radiation.
      }.merge! options

      @landed = false

      super(options)

      self.image = @frames[SPRITE_FREE] # Rock picks a random image to start with.
    end
    
    def on_stopped(sender)
      unless @landed
        @landed = true
        Sample["objects/explosion.ogg"].play_at_x(x)
        self.image = @frames[SPRITE_EMBEDDED]
        Crater.create(position: position) unless parent.client?
        # TODO: Splash and smoke?
      end
    end

    def on_being_picked_up(actor)
      self.image = @frames[SPRITE_FREE]
    end
    
    def draw
      super

      intensity = ((parent.height - z.to_f) / parent.height) - 0.75
      color = Color::GREEN.dup
      color.alpha = 100
      intensity *= (3 + Math::sin(milliseconds / 500.0))
      parent.draw_glow(x, y, color, intensity) if intensity > 0
    end
    
    def draw_self
      unless @landed
        @frames[SPRITE_FLAME].draw_rot x, y - z - height / 2, zorder, 0, 0.5, 1, 1, 2.5, FLAME_COLOR
      end

      super

      color = Status::Irradiated::OVERLAY_COLOR
      color.alpha = ((1.3 + Math::sin(milliseconds / 500.0)) * 90).to_i
      image.outline.draw_rot x, y + 1 - z, zorder, 0, 0.5, 1.0, factor_x, factor_y, color, :additive
    end 

    def on_collision(other)
      if other.is_a? Creature
        other.apply_status(:irradiated, duration: IRRADIATED_DURATION)
      end
      
      super(other)
    end
  end
end