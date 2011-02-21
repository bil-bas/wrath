require_relative 'static_object'
require_relative '../carriable'

class Rock < StaticObject
  NUM_PEBBLES = 9
  EXPLOSION_DAMAGE = 40

  include Carriable

  IMAGE_POS = [[0, 0], [1, 0]]

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
    }.merge! options

    super IMAGE_POS[rand(IMAGE_POS.size)], options
  end

  def sacrificed(player, altar)
    player.health -= EXPLOSION_DAMAGE

    NUM_PEBBLES.times do
      angle = rand(360)
      speed = 0.4 + rand(0.8)
      y_velocity = Math::sin(angle) * speed
      x_velocity = Math::cos(angle) * speed
      z_velocity = 0.5 + rand(0.9)
      Pebble.create(x: altar.x, y: altar.y, z: altar.z + altar.height,
        x_velocity: x_velocity, y_velocity: y_velocity, z_velocity: z_velocity)
    end

    destroy
  end
end