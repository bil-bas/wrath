require_relative 'static_object'

class Pebble < StaticObject
  trait :timer

  IMAGE_POS = [2, 0]

  def initialize(options = {})
    options = {
      shadow_width: 2,
    }.merge! options

    super IMAGE_POS, options
  end
end