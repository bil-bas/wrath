class Rock < Carriable
  EXPLOSION_HEALTH = -40
  EXPLOSION_FAVOR = -10

  EXPLOSION_H_SPEED = 0.4..1.2
  EXPLOSION_Z_VELOCITY = 0.5..1.4
  EXPLOSION_NUMBER = 8..12

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
      elasticity: 0.4,
      z_offset: -2,
      animation: "rock_6x6.png",
    }.merge! options

    @sacrificial_explosion = Explosion.new(type: Pebble, number: EXPLOSION_NUMBER, h_speed: EXPLOSION_H_SPEED,
                                           z_velocity: EXPLOSION_Z_VELOCITY)

    super  options
  end

  def sacrificed(player, altar)
    Sample["rock_sacrifice.wav"].play

    player.health += EXPLOSION_HEALTH
    player.favor += EXPLOSION_FAVOR

    super
  end
end