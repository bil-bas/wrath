# encoding: utf-8

require_relative 'mob'

class Virgin < Mob
  def initialize(options = {})
    options = {
      image: $window.character_sprites[2, 1],
      speed: 0.3,
    }.merge! options

    super options
  end
end