# encoding: utf-8

require_relative 'wrath_object'

class Goat < WrathObject
  def initialize(options = {})
    options = {
      image: $window.character_sprites[13, 2],
      speed: 0.5,
    }.merge! options

    @speed = options[:speed]

    super(options)
  end
end