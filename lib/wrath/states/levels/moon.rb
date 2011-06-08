module Wrath
  class Level < GameState
    # Yuggoth (Pluto), a bluish moon with low gravity. Clangers are out today, though.
    class Moon < Level
      DEFAULT_TILE = MoonDust

      GOD = Azathoth

      def medium; :space; end
      def gravity; super * 0.6; end
      
      def self.to_s; "Yuggoth"; end

      def random_tiles
        num_columns, num_rows, grid = super(DEFAULT_TILE)
        
        grid
      end
    end
  end
end