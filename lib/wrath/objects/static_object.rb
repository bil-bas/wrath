# encoding: utf-8

require_relative 'wrath_object'

class StaticObject < WrathObject
  IMAGE_WALK1 = 0
  IMAGE_WALK2 = 1
  IMAGE_LIE = 2
  IMAGE_SLEEP = 3

  def initialize(image_pos, options = {})
    options = {
    }.merge! options

    @@sprites ||= SpriteSheet.new("objects.png", 8, 8, 4)

    options[:image] = @@sprites[*image_pos]

    super 0, options
  end
end