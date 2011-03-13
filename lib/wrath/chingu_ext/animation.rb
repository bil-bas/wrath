module Chingu
  class Animation
    def initialize(options)
      #options = {:step => 1, :loop => true, :bounce => false, :width => 32, :height => 32, :index => 0, :delay => 100}.merge(options)
      options = {:step => 1, :loop => true, :bounce => false, :index => 0, :delay => 100}.merge(options)

      @loop = options[:loop]
      @bounce = options[:bounce]
      @file = options[:file]
      @index = options[:index]
      @delay = options[:delay]
      @step = options[:step] || 1
      @dt = 0

      @sub_animations = {}
      @frame_actions = []

      if @file
        unless File.exists?(@file)
          Gosu::Image.autoload_dirs.each do |autoload_dir|
            full_path = File.join(autoload_dir, @file)
            if File.exists?(full_path)
              @file = full_path
              break
            end
          end
        end

        #
        # Various ways of determening the framesize
        #
        if options[:height] && options[:width]
          @height = options[:height]
          @width = options[:width]
        elsif options[:size] && options[:size].is_a?(Array)
          @width = options[:size][0]
          @height = options[:size][1]
        elsif options[:size]
          @width = options[:size]
          @height = options[:size]
        elsif @file =~ /_(\d+)x(\d+)/
          # Auto-detect width/height from filename
          # Tilefile foo_10x25.png would mean frame width 10px and height 25px
          @width = $1.to_i
          @height = $2.to_i
        else
          # Assume the shortest side is the width/height for each frame
          @image = Gosu::Image.new($window, @file)
          @width = @height = (@image.width < @image.height) ? @image.width : @image.height
        end

        @frames = Gosu::Image.load_tiles($window, @file, @width, @height, true)
      else
        @frames = Array(options[:frames])
      end
    end
  end
end