# encoding: utf-8

require_relative 'mob'

class Knight < Mob
  IMAGE_ROW = 5

  def favor; 30; end

  def initialize(options = {})
    options = {
      speed: 0.3,
      encumbrance: 0.6,
    }.merge! options

    super IMAGE_ROW, options
  end
end