require_relative "status"

module Wrath
  class Status
    # Being on fire is no fun. Creatures will be speeded up and hurt, but plain objects won't.
    class Burning < Status
      SPEED_BONUS = 1
      DAMAGE = 2 / 1000.0
      ANIMATION_INTERVAL = 500
      DEFAULT_PRIMARY_BURN_DURATION = 5000 # Hit by a camp-fire or lava
      DEFAULT_SECONDARY_BURN_DURATION = 1000 # Hit by something that was on fire.

      GLOW_COLOR = Color.rgba(255, 255, 50, 50) # Yellowy glow.
      FLAME_COLOR = Color.rgba(255, 255, 255, 100) # Semi-transparent flames.

      def update
        owner.wound(DAMAGE * parent.frame_time, self, :over_time) if owner.is_a?(Creature) and not parent.client?

        if rand(100) < 3
          Smoke.create(parent: parent, x: random(owner.x - owner.collision_width / 2, owner.x + owner.collision_width / 2),
                       y: owner.y - owner.z - owner.collision_height - rand(3), zorder: owner.y - 0.01 + rand(0.02))
        end

        @frame_number = (milliseconds / ANIMATION_INTERVAL) % 2

        super
      end

      def draw
        $window.clip_to(0, 0, 10000, owner.y) do
          @@animation ||= Animation.new(file: "objects/fire_8x8.png")
          angle = if owner.inside_container?
                    owner.container.x_velocity
                  else
                    owner.x_velocity
                  end
          angle *= - 15
          @@animation[@frame_number].draw_rot owner.x, owner.y - owner.z - owner.collision_height / 3.0, owner.y - 0.01,
                           angle, 0.5, 1,
                           owner.collision_width * 1.1 / @@animation[0].width,
                           owner.collision_height * 1.5 / @@animation[0].height, FLAME_COLOR, :additive
        end

        intensity = [1.5 - (owner.z * 0.05), 0].max
        parent.draw_glow(owner.x, owner.y, GLOW_COLOR, intensity)
      end

      def on_applied(sender, creature)
        @frame_number = 0
        creature.speed += SPEED_BONUS if creature.respond_to? :speed=
      end

      def on_removed(sender, creature)
        creature.speed -= SPEED_BONUS if creature.respond_to? :speed=
      end
    end
  end
end