# Crown of levitation. It makes the player float, but costs favour.
class Crown < StaticObject
  LEVITATE_HEIGHT = 15
  LEVITATE_SPEED = 0.05
  FAVOUR_COST = 1 / 1000.0 # Per second

  trait :timer

  include Carriable

  def initialize(options = {})
    options = {
      encumbrance: -0.2, # Slightly faster than walking.
      elasticity: 0.2,
      animation: "crown_6x2.png",
    }.merge! options

    super options
  end

  def update
    super

    if @carrier and @carrier.favor > 0
      @carrier.favor -= FAVOUR_COST * $window.dt
      @carrier.z_velocity = [LEVITATE_HEIGHT - @carrier.z, 0].max * LEVITATE_SPEED
    end
  end
end