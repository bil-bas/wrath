module Wrath
  # A part of the HUD that shows a coloured bar to indicate a value.
  class Bar < GameObject
    DEFAULT_BACKGROUND_COLOR = Color.rgba(0, 0, 0, 100)
    DEFAULT_COLOR = Color.rgb(255, 255, 255)

    include Log

    # 0.0 to 1.0
    attr_reader :value

    def value=(value); @value = [[value, 0.0].max, 1.0].min; end

    def initialize(options = {})
      options = {
          background_color: DEFAULT_BACKGROUND_COLOR,
          color: DEFAULT_COLOR,
          zorder: ZOrder::GUI,
          border_width: 1,
          border_height: 1,
          value: 0,
          width: 30,
          height: 4,
      }.merge! options

      super options

      @width = options[:width]
      @height = options[:height]
      @border_width = options[:border_width]
      @border_height = options[:border_height]
      @color = options[:color].dup
      @background_color = options[:background_color].dup
      @value = options[:value]

      @@pixel = $window.pixel
    end

    def draw
      # Draw the background color for the outer box.
      @@pixel.draw @x, @y, @zorder,
                  @width, @height,
                  @background_color

      # Draw the bar itself, inside the box.
      bar_width = (@width - @border_width * 2) * @value
      @@pixel.draw @x + @border_width, @y + @border_height, @zorder,
                  bar_width, @height - @border_height * 2,
                  @color

    end
  end
end