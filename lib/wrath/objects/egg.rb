require_relative 'static_object'

class Egg < StaticObject
  include Carriable

  trait :timer

  def initialize(options = {})
    options = {
      encumbrance: 0,
      elasticity: 0.4,
      animation: "egg_4x5.png",
    }.merge! options

    super options
  end
end