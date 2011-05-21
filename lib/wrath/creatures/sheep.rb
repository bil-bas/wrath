module Wrath

class Sheep < Animal
  def initialize(options = {})
    options = {
      favor: 6,
      health: 20,
      vertical_jump: 0.3,
      horizontal_jump: 0.6,
      elasticity: 0.8,
      jump_delay: 1000,
      encumbrance: 0.2,
      z_offset: -2,
      animation: "sheep_8x8.png",
    }.merge! options

    super(options)
  end
end
end