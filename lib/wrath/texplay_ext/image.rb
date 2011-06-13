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
      unless defined? @silhouette
        refresh_cache
        @silhouette = self.dup
        @silhouette.clear(dest_ignore: :transparent, color: :white)
      end

      @silhouette
    end

    # Array of [colour, x, y] for all solid pixels in the object.
    def explosion
      unless defined? @explosion
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
    
    def self.create(width, height, options = {})
      TexPlay.create_image($window, width, height, options)
    end
    
    # Redraw the outline image, assuming the image has changed.
    public
    def outline
      unless @outline            
        refresh_cache      
        clear(dest_select: :transparent)   
        
        @outline = Image.create(width + 2, height + 2)
         
        # Find the top and bottom edges.
        height.times do |y|
          x = 0

          while x and x < width
            if x == 0 and not transparent_pixel?(x, y)
              # If the first pixel is opaque, then put an outline above it.
              @outline.set_pixel(0, y + 1)
              x = 1
            else
              found = line(x, y, width - 1, y, trace: { while_color: :alpha })
              x = found ? found[0] : nil
              @outline.set_pixel(x, y + 1) if x
            end

            if x and x < width
              found = line(x, y, width - 1, y, trace: { until_color: :alpha })
              x = found ? found[0] : width
              @outline.set_pixel(x + 1, y + 1)
            end
          end
        end

        # Find the left and right edges.
        width.times do |x|
          y = 0

          while y and y < height
            if y == 0 and not transparent_pixel?(x, y)
              # If the first pixel is opaque, then put an outline to the left of it.
              @outline.set_pixel(x + 1, 0)
              y = 1
            else
              found = line(x, y, x, height - 1, trace: { while_color: :alpha })
              y = found ? found[1] : nil
              @outline.set_pixel(x + 1, y) if y
            end

            if y and y < height
              found = line(x, y, x, height - 1, trace: { until_color: :alpha })
              y = found ? found[1] : height
              @outline.set_pixel(x + 1, y + 1)
            end
          end
        end
      end

      @outline
    end
  end
end