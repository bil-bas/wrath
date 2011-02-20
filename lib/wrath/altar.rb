# encoding: utf-8

require_relative 'wrath_object'

class Altar < WrathObject
  def initialize(options = {})
    options = {
      image: $window.furniture_sprites[1, 1],
      x: 80,
      y: 60,
    }.merge! options

    super(options)
  end
end