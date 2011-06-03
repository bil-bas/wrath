module Wrath
  # Storm
  class Ai < God
    DISASTER_DARKNESS_COLOR = Color.rgba(0, 0, 0, 120)

    def self.to_s; "The Rogue AI"; end

    def on_disaster_start(sender)
      schedule_gas unless parent.client?
    end

    def on_disaster_end(sender)
      unless parent.client?
        GasJet.all.each(&:destroy)
      end
    end

    def schedule_gas
      after(150 + rand(250)) do
        if in_disaster?
          GasJet.create(position: spawn_position(0))
          schedule_gas
        end
      end
    end

    def draw
      super

      # Draw overlay to make it look dark.
      if in_disaster?
        $window.pixel.draw(0, 0, ZOrder::FOREGROUND, $window.retro_width, $window.retro_height, DISASTER_DARKNESS_COLOR)
        # TODO: Add emergency lighting.
      end
    end
  end
end