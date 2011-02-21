# encoding: utf-8

require_relative 'wrath_object'

class Player < WrathObject
  attr_reader :speed

  def initialize(options = {})
    options = {
      image: $window.character_sprites[3, 5],
      speed: 0.5,
    }.merge! options

    @speed = options[:speed]

    super(options)
  end
end