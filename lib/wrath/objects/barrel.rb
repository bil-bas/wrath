module Wrath
  class Barrel < Chest
    ROLLING_SPRITE_FRAME = 2

    def initialize(options = {})
      options = {
          animation: "barrel_6x8.png",
          elasticity: 0.9,
          encumbrance: 0.3,
      }.merge! options

      super(options)
    end

    def on_being_picked_up(actor)
      self.image = @frames[ROLLING_SPRITE_FRAME]
    end
  end
end