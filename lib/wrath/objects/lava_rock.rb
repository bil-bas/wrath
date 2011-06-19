module Wrath
  class LavaRock < Rock
    EXPLOSION_H_SPEED = 0.4..1.2
    EXPLOSION_Z_VELOCITY = 0.5..1.4
    FIRE_EXPLOSION_NUMBER = 1..3

    COLOR = Color.rgb(255, 150, 100)

    def initialize(options = {})
      options = {
          color: COLOR.dup,
          elasticity: 0,
      }.merge! options

      super(options)

      @@fire_explosion ||= Emitter.new(Fire, parent, number: FIRE_EXPLOSION_NUMBER, h_speed: EXPLOSION_H_SPEED,
                                             z_velocity: EXPLOSION_Z_VELOCITY)
    end

    def on_stopped(sender)
      pos = position
      pos[2] += height

      Sample["objects/explosion.ogg"].play_at_x(x)
      tile = parent.map.replace_tile(x, y, Lava)
      tile.filled = true

      unless parent.client?
        @@fire_explosion.emit(pos, thrown_by: [self])
        destroy
      end
    end
  end
end