module Wrath
  class Sheep < Animal
    def initialize(options = {})
      options = {
          favor: 6,
          health: 20,
          vertical_jump: 1,
          speed: 1.2,
          elasticity: 0.8,
          move_interval: 1000,
          encumbrance: 0.2,
          animation: "sheep_8x8.png",
      }.merge! options

      super(options)
    end
  end
end