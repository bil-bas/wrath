require_relative 'static_object'

class Egg < StaticObject
  include Carriable

  trait :timer

  IMAGE_POS = [0, 6]

  def initialize(options = {})
    options = {
      encumbrance: 0,
      elasticity: 0.4,
      shadow_width: 4,
    }.merge! options

    super IMAGE_POS, options
  end
end