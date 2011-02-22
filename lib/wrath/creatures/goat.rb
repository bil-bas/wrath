# encoding: utf-8

require_relative 'mob'

class Goat < Mob
  def favor; 20; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.3,
      horizontal_jump: 0.6,
      elasticity: 0.8,
      jump_delay: 1000,
      encumbrance: 0.2,
      animation: "goat_8x8.png",
    }.merge! options

    super(options)
  end
end