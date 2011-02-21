# encoding: utf-8

require_relative '../objects/wrath_object'

class Creature < WrathObject
  IMAGE_WALK1 = 0
  IMAGE_WALK2 = 1
  IMAGE_LIE = 2
  IMAGE_SLEEP = 3

  def initialize(image_row, options = {})
    options = {
    }.merge! options

    @@sprites ||= SpriteSheet.new("creatures.png", 8, 8, 4)

    @walking_images = @@sprites[IMAGE_WALK1, image_row], @@sprites[IMAGE_WALK2, image_row]
    @lie_image = @@sprites[IMAGE_LIE, image_row]
    @sleep_image = @@sprites[IMAGE_SLEEP, image_row]

    options[:image] = @walking_images[0]

    super 0, options
  end
end