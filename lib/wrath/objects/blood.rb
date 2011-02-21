require_relative 'static_object'

class Blood < StaticObject
  trait :timer

  IMAGE_POS = [2, 1]

  def initialize(options = {})
    options = {
      shadow_width: 2,
        elasticity: 0,
    }.merge! options

    super IMAGE_POS, options
  end
end