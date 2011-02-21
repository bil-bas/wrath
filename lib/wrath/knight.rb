# encoding: utf-8

require_relative 'mob'

class Knight < Mob
  def favor; 30; end

  def initialize(options = {})
    options = {
      image: $window.character_sprites[8, 0],
      speed: 0.3,
    }.merge! options

    super options
  end
end