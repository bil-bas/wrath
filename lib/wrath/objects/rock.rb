require_relative 'static_object'
require_relative '../carriable'

class Rock < StaticObject
  NUM_PEBBLES = 9

  EXPLOSION_HEALTH = -40
  EXPLOSION_FAVOR = -10

  include Carriable

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
      elasticity: 0.4,
      animation: "rock_6x6.png",
    }.merge! options

    super  options
  end

  def sacrificed(player, altar)
    player.health += EXPLOSION_HEALTH
    player.favor += EXPLOSION_FAVOR

    NUM_PEBBLES.times do
      angle = rand(360)
      speed = 0.4 + rand(0.8)
      y_velocity = Math::sin(angle) * speed
      x_velocity = Math::cos(angle) * speed
      z_velocity = 0.5 + rand(0.9)
      Pebble.create(x: altar.x, y: altar.y, z: altar.z + altar.height,
        x_velocity: x_velocity, y_velocity: y_velocity, z_velocity: z_velocity)
    end

    super
  end
end