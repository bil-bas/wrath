# encoding: utf-8

class Horse < Mob
  def favor; 20; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.1,
      horizontal_jump: 0.1,
      elasticity: 0.6,
      jump_delay: 2000,
      encumbrance: 0.4,
      animation: "horse_12x11.png",
    }.merge! options

    super(options)
  end
end