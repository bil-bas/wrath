module Wrath
class Rock < DynamicObject
  EXPLOSION_HEALTH = -40

  EXPLOSION_H_SPEED = 0.4..1.2
  EXPLOSION_Z_VELOCITY = 0.5..1.4
  EXPLOSION_NUMBER = 8..12

  DAMAGE = 5

  def dangerous?(other); false; end # No-one "avoids" rocks, though they can hurt in certain circumstances.
  def can_hit?(other); thrown? and super(other); end

  def initialize(options = {})
    options = {
        damage_per_hit: DAMAGE,
        favor: -10,
        encumbrance: 0.6,
        elasticity: 0.5,
        z_offset: -2,
        animation: "rock_6x6.png",
    }.merge! options

    super options

    self.image = @frames.frames.sample
  end

  public
  def can_spawn_onto?(tile)
    true
  end

  def sacrificed(actor, altar)
    actor.health += EXPLOSION_HEALTH unless parent.client?

    super
  end

  def on_collision(other)
    case other
      when Mushroom, Egg
        if (not inside_container?) and z > ground_level
          other.destroy
        end
    end

    super(other)
  end
end
end