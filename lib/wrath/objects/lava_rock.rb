module Wrath
  class LavaRock < Rock
    EXPLOSION_H_SPEED = 0.4..1.2
    EXPLOSION_Z_VELOCITY = 0.5..1.4
    FIRE_EXPLOSION_NUMBER = 1..3

    def initialize(options = {})
      super(options)

      @@fire_explosion ||= Emitter.new(Fire, parent, number: FIRE_EXPLOSION_NUMBER, h_speed: EXPLOSION_H_SPEED,
                                             z_velocity: EXPLOSION_Z_VELOCITY)
    end

    def on_bounced
      unless parent.client?
        pos = position
        pos[2] += height
        @@fire_explosion.emit(pos, thrown_by: [self])

        destroy
      end
    end

    def destroy
      Sample["objects/rock_sacrifice.ogg"].play

      tile = parent.map.replace_tile(x, y, Lava)
      tile.filled = true

      super
    end
  end
end