# Crown of levitation. It makes the player float, but costs favour.
class Crown < Carriable
  LEVITATE_HEIGHT = 15
  LEVITATE_SPEED = 0.05
  FAVOUR_COST = 1 / 1000.0 # Per second

  trait :timer

  # Speeds the user up while flying, but not on the ground.
  def encumbrance
    (empowered? and @carrier.z > @carrier.ground_level) ? -0.25 : 0
  end

  def empowered?
    @carrier and @carrier.favor > 0
  end

  def initialize(options = {})
    options = {
      elasticity: 0.2,
      z_offset: -2,
      animation: "crown_6x2.png",
    }.merge! options

    super options
  end

  def update
    if empowered?
      @carrier.favor -= FAVOUR_COST * $window.dt
      @carrier.z_velocity = [LEVITATE_HEIGHT - @carrier.z, 0].max * LEVITATE_SPEED
    end

    super
  end
end