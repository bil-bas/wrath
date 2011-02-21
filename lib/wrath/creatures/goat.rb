# encoding: utf-8

require_relative 'mob'

class Goat < Mob
  IMAGE_ROW = 3

  def favor; 20; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.3,
      horizontal_jump: 0.6,
      elasticity: 0.8,
      jump_delay: 1000,
      encumbrance: 0.2,
    }.merge! options

    super(IMAGE_ROW, options)
  end
end