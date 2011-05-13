module Wrath
  class God < GameObject
    include Log

    BACKGROUND_COLOR = Color.rgba(0, 0, 0, 100)
    ANGER_COLOR = Color.rgb(255, 0, 255)
    ANGER_WIDTH = 30
    BORDER_WIDTH = 1

    def initialize(options = {})
      options = {
          x: $window.retro_width / 2,
          y: 1,
          zorder: ZOrder::GUI,
          rotation_center: :top_center,
      }.merge! options

      super options

      @max_anger = 60 # Time before the god goes crazy (game ends).
      @anger = 0

      @animation_cache ||= {}
      sprite_name = self.class.name.downcase[/[a-z]+$/]
      @animation_cache[options[:animation]] ||= Animation.new(file: "gods/#{sprite_name}_8x8.png", delay: 500)
      @frames = @animation_cache[options[:animation]]
      self.image = @frames[0]
      @animation_index = nil

      @anger_bar = Bar.create(x: x - ANGER_WIDTH / 2, y: y + image.height, width: ANGER_WIDTH, height: 4, value: 0.5, color: ANGER_COLOR)
    end

    def update
      @anger = [@anger + parent.frame_time / 1000.0, @max_anger].min
      @anger_bar.value = @anger / @max_anger
      new_animation_index = (@anger_bar.value * 4).floor
      if new_animation_index != @animation_index
        @animation_index = new_animation_index
        frame_index = @animation_index * 2
        @current_animation = @frames[frame_index..(frame_index + 1)]
      end

      self.image = @current_animation.next

      super
    end

    def draw
      $window.pixel.draw x - BORDER_WIDTH - image.width / 2, y - BORDER_WIDTH, zorder, 10, 9, BACKGROUND_COLOR
      super
    end
  end
end