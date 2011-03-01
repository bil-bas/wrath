class Message
  class Map < Message
    # TODO: Send a default tile, so that we don't have to send the whole array.

    value :tiles, nil

    def initialize(options = {})
      # Convert class matrix to symbols.
      if options[:tiles][0][0].is_a? Class
        options[:tiles] = options[:tiles].map do |row|
          row.map {|klass| klass.name.to_sym }
        end
      end

      super(options)
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