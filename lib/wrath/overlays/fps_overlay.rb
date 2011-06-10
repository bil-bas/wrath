module Wrath
  class FPSOverlay < Overlay
    TEXT_COLOR = Color.rgba(255, 255, 255, 100)
    FONT_SIZE = 24

    def initialize
      super

      @font = Font[FONT_SIZE]
    end

    def draw
      @font.draw "FPS: #{$window.fps} (#{$window.potential_fps})", 0, 40, ZOrder::GUI, 1, 1, TEXT_COLOR
    end
  end
end