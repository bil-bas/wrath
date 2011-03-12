# encoding: utf-8

class Knight < Mob
  def initialize(options = {})
    options = {
      favor: 30,
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.4,
      jump_delay: 800,
      encumbrance: 0.5,
      z_offset: -2,
      animation: "knight_8x8.png",
    }.merge! options

    super options
  end
end