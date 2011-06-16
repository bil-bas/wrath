module Wrath
  class FPSOverlay < Overlay
    TEXT_COLOR = Color.rgba(255, 255, 255, 100)
    SHADOW_COLOR = Color.rgba(0, 0, 0, 100)
    SHADOW_OFFSET = 2
    FONT_SIZE = 24

    def initialize
      super(visible: true)

      @font = Font[FONT_SIZE]
    end

    def draw
      @font.draw "FPS: #{$window.fps} (#{$window.potential_fps})", SHADOW_OFFSET, SHADOW_OFFSET, ZOrder::GUI, 1, 1, SHADOW_COLOR
      @font.draw "FPS: #{$window.fps} (#{$window.potential_fps})", 0, 0, ZOrder::GUI, 1, 1, TEXT_COLOR
    end
  end
end