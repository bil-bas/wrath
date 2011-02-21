# encoding: utf-8

require_relative 'mob'

class Knight < Mob
  IMAGE_ROW = 5

  def favor; 30; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.4,
      jump_delay: 800,
      encumbrance: 0.4,
    }.merge! options

    super IMAGE_ROW, options
  end
end