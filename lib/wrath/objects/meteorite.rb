module Wrath
  class Meteorite < Rock
    IRRADIATED_DURATION = 6000

    SPRITE_LANDING = 0
    SPRITE_EMBEDDED = 1
    SPRITE_FREE = 2
    
    def initialize(options = {})
      options = {
          favor: 2,
          animation: "meteorite_7x13.png",
          elasticity: 0,
          encumbrance: 1.3, # Can be heavy, since it also gives strength via radiation.
      }.merge! options

      @landed = false

      super(options)
    end
    
    def on_stopped
      unless @landed
        @landed = true
        Sample["objects/rock_sacrifice.ogg"].play
        self.image = @frames[SPRITE_EMBEDDED]
        Crater.create(position: position) if not parent.client?
      end

      super
    end

    def on_being_picked_up(actor)
      self.image = @frames[SPRITE_FREE]
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

      $window.clip_to(0, 0, 10000, y) do
        color = Status::Irradiated::OVERLAY_COLOR
        color.alpha = ((1.3 + Math::sin(milliseconds / 500.0)) * 90).to_i
        image.outline.draw_rot x, y + 1 - z, zorder, 0, 0.5, 1.0, factor_x, factor_y, color, :additive
      end
    end 

    def on_collision(other)
      if other.is_a? Creature
        other.apply_status(:irradiated, duration: IRRADIATED_DURATION)
      end
      
      super(other)
    end
  end
end