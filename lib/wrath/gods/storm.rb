module Wrath
  # Storm
  class Storm < God
    LIGHTNING_COLOR = Color.rgba(255, 255, 255, 50)

    def on_disaster_start(sender)
      Sample["objects/rock_sacrifice.ogg"].play
    end

    def draw
      super

      # Draw overlay to make it look dark.
      if @in_disaster
        color = LIGHTNING_COLOR
        mode = :additive
      else
        color = parent.class::DARKNESS_COLOR
        mode = :default
      end

      $window.pixel.draw(0, 0, ZOrder::FOREGROUND, $window.retro_width, $window.retro_height, color, mode )
    end
  end
end