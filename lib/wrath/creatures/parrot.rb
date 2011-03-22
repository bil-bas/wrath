module Wrath
  class Parrot < Mob
    def ground_level; super + ((@state == :thrown) ? 0 : 6); end

    def initialize(options = {})
      options = {
        health: 10,
        favor: 10,
        vertical_jump: 0.1,
        horizontal_jump: 0.4,
        elasticity: 0.5,
        jump_delay: 0,
        animation: "parrot_8x8.png",
        factor: 0.7,
      }.merge! options

      super(options)
    end
  end
end