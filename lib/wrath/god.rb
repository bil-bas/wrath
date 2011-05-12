module Wrath
  class God < GameObject
    include Log

    BACKGROUND_COLOR = Color.rgba(0, 0, 0, 100)
    ANGER_COLOR = Color.rgb(255, 0, 255)
    ANGER_WIDTH = 30
    BORDER_WIDTH = 1

    def initialize(options = {})
      options = {
          animation: "gods/ship_8x8.png",
          x: $window.retro_width / 2,
          y: 1,
          zorder: ZOrder::GUI,
          rotation_center: :top_center,
      }.merge! options

      super options

      @max_anger = 1.5 * 60 # Time before the god goes crazy (game ends).
      @anger = 0

      @animation_cache ||= {}
      @animation_cache[options[:animation]] ||= Animation.new(file: options[:animation], delay: 500)
      @frames = @animation_cache[options[:animation]]
      self.image = @frames[0]
      @animation_index = -1

      @anger_bar = Bar.create(x: x - ANGER_WIDTH / 2, y: y + image.height, width: ANGER_WIDTH, height: 4, value: 0.5, color: ANGER_COLOR)
    end

    def update
      @anger = [@anger + parent.frame_time / 1000.0, @max_anger].min
      @anger_bar.value = @anger / @max_anger
      new_animation_index = (@anger_bar.value * @frames.frames.size).to_i
      if new_animation_index != @animation_index
        @animation_index = new_animation_index
        @animation =  case @animation_index
                        when 0
                          @frames[0..0]
                        when 1
                          @frames[0..1]
                        when 2
                          @frames[1..2]
                        when 3
                          @frames[2..3]
                        when 4
                          @frames[3..3]
                       end
      end


      self.image = @animation.next

      super
    end

    def draw
      $window.pixel.draw x - BORDER_WIDTH - image.width / 2, y - BORDER_WIDTH, zorder, 10, 9, BACKGROUND_COLOR
      super
    end
  end
end