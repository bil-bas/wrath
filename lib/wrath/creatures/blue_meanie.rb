module Wrath
  class BlueMeanie < Mob
    def ground_level; super + ((@state == :thrown) ? 0 : 6); end

    def initialize(options = {})
      options = {
        favor: 30,
        health: 20,
        vertical_jump: 0.1,
        horizontal_jump: 0.4,
        elasticity: 0.5,
        jump_delay: 0,
        encumbrance: 0.4,
        z_offset: -2,
        animation: "blue_meanie_8x8.png",
      }.merge! options

      super(options)
    end
  end
end