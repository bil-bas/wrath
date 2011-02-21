# encoding: utf-8

require_relative 'mob'

class Goat < Mob
  def favor; 10; end

  def initialize(options = {})
    options = {
      image: $window.character_sprites[2, 13],
      speed: 0.5,
    }.merge! options

    super(options)
  end
end