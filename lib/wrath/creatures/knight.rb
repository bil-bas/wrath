# encoding: utf-8

class Knight < Mob
  def favor; 30; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.4,
      jump_delay: 800,
      encumbrance: 0.4,
      animation: "knight_8x8.png",
    }.merge! options

    super options
  end
end