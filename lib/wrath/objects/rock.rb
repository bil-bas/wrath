module Wrath
class Rock < DynamicObject
  DAMAGE = 10 # Damage from dropping a rock on someone.
  EXPLOSION_HEALTH = -40

  EXPLOSION_H_SPEED = 0.4..1.2
  EXPLOSION_Z_VELOCITY = 0.5..1.4
  EXPLOSION_NUMBER = 8..12

  def initialize(options = {})
    options = {
      favor: -10,
      encumbrance: 0.6,
      elasticity: 0.4,
      z_offset: -2,
      animation: "rock_6x6.png",
    }.merge! options

    @sacrificial_explosion = Emitter.new(Pebble, parent, number: EXPLOSION_NUMBER, h_speed: EXPLOSION_H_SPEED,
                                           z_velocity: EXPLOSION_Z_VELOCITY)

    super  options
  end

  def sacrificed(actor, altar)
    Sample["rock_sacrifice.wav"].play

    actor.health += EXPLOSION_HEALTH unless parent.client?

    super
  end

  def on_collision(other)
    case other
      when Mushroom, Egg
        if (not carried?) and z > ground_level
          other.destroy
        end

      when Creature
        if not thrown_by.include? other and (not carried?) and z > ground_level
          other.health -= DAMAGE
          @thrown_by << other
        end
    end

    super(other)
  end
end
end