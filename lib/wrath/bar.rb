module Wrath
  # A part of the HUD that shows a coloured bar to indicate a value.
  class Bar < GameObject
    unless defined? DEFAULT_COLOR
      DEFAULT_COLOR = Color.rgb(255, 255, 255)
      BACKGROUND_COLOR = Color.rgb(0, 0, 0)
    end

    include Log

    # 0.0 to 1.0
    attr_reader :value
    attr_reader :height, :width

    def value=(value); @value = [[value, 0.0].max, 1.0].min; end

    def initialize(options = {})
      options = {
          color: DEFAULT_COLOR,
          zorder: ZOrder::GUI,
          border_width: 1,
          border_height: 1,
          value: 0,
          width: 30,
          height: 2,
      }.merge! options

      super options

      @width = options[:width]
      @height = options[:height]
      @color = options[:color].dup
      @value = options[:value]

      @@pixel = $window.pixel
    end

    def draw
      @@pixel.draw @x, @y, @zorder, @width * @value, @height, @color

    end
  end
end