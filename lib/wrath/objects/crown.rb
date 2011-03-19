# Crown of levitation. It makes the player float, but costs favour.
module Wrath
class Crown < DynamicObject
  LEVITATE_HEIGHT = 15
  LEVITATE_SPEED = 0.05
  FAVOUR_COST = 1 / 1000.0 # Per second

  trait :timer

  # Speeds the user up while flying, but not on the ground.
  def encumbrance
    (empowered? and container.z > container.ground_level) ? -0.25 : 0
  end

  def empowered?
    inside_container? and container.player and container.player.favor > 0
  end

  def initialize(options = {})
    options = {
      favor: 5,
      elasticity: 0.2,
      z_offset: -2,
      animation: "crown_6x2.png",
    }.merge! options

    super options
  end

  def update
    if empowered?
      container.player.favor -= FAVOUR_COST * frame_time
      container.z_velocity = [LEVITATE_HEIGHT - container.z, 0].max * LEVITATE_SPEED
    end

    super
  end
end
end