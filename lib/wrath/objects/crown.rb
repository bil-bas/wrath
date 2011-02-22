require_relative 'static_object'
require_relative '../carriable'

class Crown < StaticObject

  include Carriable

  def initialize(options = {})
    options = {
      encumbrance: 0,
      elasticity: 0.2,
      animation: "crown_6x2.png",
    }.merge! options

    super options
  end
end