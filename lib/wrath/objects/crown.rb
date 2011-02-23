require_relative 'static_object'
require_relative '../carriable'

# Crown of levitation.
class Crown < StaticObject
  LEVITATE_HEIGHT = 12.0
  LEVITATE_SPEED = 0.05

  trait :timer

  include Carriable

  def initialize(options = {})
    options = {
      encumbrance: 0.5,
      elasticity: 0.2,
      animation: "crown_6x2.png",
    }.merge! options

    super options
  end

  def update
    super

    if @carrier
      @carrier.z_velocity = [LEVITATE_HEIGHT - @carrier.z, 0].max * LEVITATE_SPEED
    end
  end
end