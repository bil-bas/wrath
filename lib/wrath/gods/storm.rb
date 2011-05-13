module Wrath
  # Storm
  class Storm < God
    LIGHTNING_COLOR = Color.rgba(255, 255, 255, 50)

    def disaster_duration; 300 + 20 * @num_disasters; end

    def disaster
      super
      Sample["objects/rock_sacrifice.wav"].play
    end

    def draw
      super

      # Draw overlay to make it look dark.
      if @disaster_duration > 0
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