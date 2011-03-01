# encoding: utf-8

class Horse < Mob
  def favor; 20; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.1,
      horizontal_jump: 0.1,
      elasticity: 0.6,
      factor_x: 1.4,
      factor_y: 1.2,
      jump_delay: 2000,
      encumbrance: 0.4,
      animation: "horse_8x8.png",
    }.merge! options

    super(options)
  end
end