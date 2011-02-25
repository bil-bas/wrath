class Message
  class Map < Message
    # TODO: Send a default tile, so that we don't have to send the whole array.

    value :tiles, nil

    def initialize(*args)
      super(*args)
    end

    def process
      class_grid = tiles.map do |row|
                     row.map { |name| Kernel::const_get(name) }
                   end
      $window.current_game_state.create_tiles(class_grid)

      puts "Created map of tiles"
    end
  end
end