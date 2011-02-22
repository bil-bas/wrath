require_relative 'static_object'
require_relative '../carriable'

class Crown < StaticObject

  include Carriable

  IMAGE_POS = [0, 4]

  def initialize(options = {})
    options = {
      encumbrance: 0,
      elasticity: 0.2,
      shadow_width: 6,
    }.merge! options

    super IMAGE_POS, options
  end
end