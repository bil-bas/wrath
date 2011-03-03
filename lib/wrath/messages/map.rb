class Message
  class Map < Message
    def initialize(tiles)
      @tiles = tiles
    end

    def process
      $window.current_game_state.create_tiles(@tiles)

      puts "Created map of tiles"
    end
  end
end