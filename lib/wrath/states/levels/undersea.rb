module Wrath
  class Level
    class Undersea < Level
      trait :timer

      DEFAULT_TILE = Sand

      FILTER_COLOR = Color.rgba(0, 100, 200, 100)

      GOD = Volcano

      SPAWNS = {
          DeepOne => 4,
          Snake => 1,
          Pirate => 1,
          Shark => 2,
      }

      # This is relative to the altar.
      PLAYER_SPAWNS = [[-12, 0], [12, 0]]

      def self.to_s; "Davey Jones' Locker (of Doom)"; end

      def gravity; super * 0.3; end

      def pushed
        every(Seaweed::ANIMATION_DELAY) { Seaweed.all.each(&:animate) }
      end

      def create_objects
        super(PLAYER_SPAWNS)

        # Inanimate objects.
        1.times { OgreSkull.create }
        2.times { TreasureChest.create }
        2.times { Clam.create }
        5.times { Rock.create }

        # Static objects.
        3.times { Boulder.create }
        12.times { Seaweed.create }

        # Top "blockers", not really tangible, so don't update/sync them.
        [10, 16].each do |y|
          x = -14
          while x < $window.retro_width + 20
            Seaweed.create(x: x, y: rand(4) + y)
            x += 6 + rand(6)
          end
        end
      end

      def random_tiles
        num_columns, num_rows, grid = super(DEFAULT_TILE)

        grid
      end

      def update
        # Slow everything down, due to water resistance.
        objects.each do |object|
          if object.is_a? Fire
            object.destroy
          elsif object.is_a? DynamicObject and object.thrown?
            # Todo: Make the dampening based on velocity, so faster things slow quicker.
            multiplier = 1.0 - 0.001 * frame_time
            object.x_velocity *= multiplier
            object.y_velocity *= multiplier
            object.z_velocity *= multiplier
          end
        end

        super
      end

      def draw
        super

        $window.pixel.draw(0, 0, ZOrder::FOREGROUND, $window.width, $window.height, FILTER_COLOR)
      end
    end
  end
end