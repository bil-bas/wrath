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

      def medium; :space; end
      def gravity; super * 0.6; end
      
      def self.to_s; "Yuggoth"; end

      def create_objects
        super(PLAYER_SPAWNS)

        # Inanimate objects.
        15.times { MoonRock.create }

        # Static objects.
        8.times { Crater.create }
        3.times { CraterWithLid.create }
      end

      def random_tiles
        num_columns, num_rows, grid = super(DEFAULT_TILE)
        
        grid
      end
    end
  end
end