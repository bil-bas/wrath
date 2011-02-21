# encoding: utf-8

require_relative 'mob'

class Chicken < Mob
  IMAGE_ROW = 2

  def favor; 10; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.1,
      horizontal_jump: 0.2,
      jump_delay: 250,
      encumbrance: 0.2,
      shadow_width: 6,
    }.merge! options

    super(IMAGE_ROW, options)
  end
end