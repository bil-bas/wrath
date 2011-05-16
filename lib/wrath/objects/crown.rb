# Crown of healing. It heals the player, but costs favour.
module Wrath
class Crown < DynamicObject
  HEAL_RATE = 4 / 1000.0
  FAVOUR_COST = 2 / 1000.0 # Per second

  GLOW_COLOR = Color.rgba(0, 255, 0, 100)

  trait :timer

  def empowered?
    inside_container? and container.controlled_by_player? and
        container.player.favor > 0 and container.health < container.max_health
  end

  def initialize(options = {})
    options = {
      favor: 5,
      encumbrance: 0,
      elasticity: 0.2,
      z_offset: -2,
      animation: "crown_6x2.png",
    }.merge! options

    super options
  end

  def update
    if empowered?
      container.player.favor -= FAVOUR_COST * frame_time
      container.health += HEAL_RATE * frame_time
    end

    super
  end

  def draw
    if empowered?
      parent.draw_glow(x, y, GLOW_COLOR, 0.6)
    end

    super
  end
end
end