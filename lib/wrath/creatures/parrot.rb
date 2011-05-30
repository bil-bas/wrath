module Wrath
  class Parrot < Animal
    def initialize(options = {})
      options = {
          flying_height: 4,
          jump_delay: 0,
          health: 10,
          favor: 4,
          vertical_jump: 0.1,
          horizontal_jump: 0.4,
          elasticity: 0.5,
          animation: "parrot_8x8.png",
          factor: 0.7,
      }.merge! options

      super(options)
    end
  end
end