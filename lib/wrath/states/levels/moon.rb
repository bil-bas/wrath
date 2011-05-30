module Wrath
  class Level < GameState
    # Yuggoth (Pluto), a bluish moon with low gravity. Clangers are out today, though.
    class Moon < Level
      DEFAULT_TILE = MoonDust

      GOD = Azathoth
      SPAWNS = {
          MiGo => 5,
          Nightgaunt => 3,
          Cultist => 2,
      }

      # This is relative to the altar.
      PLAYER_SPAWNS = [[-12, 0], [12, 0]]

      def gravity; super * 0.6; end
      
      def self.to_s; "Yuggoth"; end

      def create_objects
        super(PLAYER_SPAWNS)

        # Inanimate objects.
        12.times { Rock.create(color: Color::BLUE) }

        # Static objects.
        6.times { Boulder.create(color: Color::BLUE) }

        # Top "blockers", not really tangible, so don't update/sync them.
        [10, 16].each do |y|
          x = -14
          while x < $window.retro_width + 20
            Boulder.create(x: x, y: rand(4) + y, paused: true, color: Color::BLUE)
            x += 6 + rand(6)
          end
        end
      end

      def random_tiles
        num_columns, num_rows, grid = super(DEFAULT_TILE)
        
        (12 + rand(5)).times do
          grid[rand(num_rows)][rand(num_columns)] = MoonCrater
        end
        
        grid
      end
    end
  end
end