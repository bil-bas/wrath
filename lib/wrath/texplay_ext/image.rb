module Gosu
  class Image
    def self.new(*args, &block)
      args[0] = $window # MONKEYPATCH: images created as tiles can't otherwise be duplicated.

      options = args.last.is_a?(Hash) ? args.pop : {}
      # invoke old behaviour
      obj = original_new(*args, &block)

      prepare_image(obj, args.first, options)
    end

    # A white silhouette of the image.
    def silhouette
      unless @silhouette
        refresh_cache
        @silhouette = self.dup
        @silhouette.clear(dest_ignore: :transparent, color: :white)
      end

      @silhouette
    end

    # Array of [colour, x, y] for all solid pixels in the object.
    def explosion
      unless @explosion
        refresh_cache
        @explosion = []
        each do |color, x, y|
          if color[3] > 0.1
            @explosion << [Color.from_texplay(color), x, y]
          end
        end
      end

      @explosion
    end
  end
end