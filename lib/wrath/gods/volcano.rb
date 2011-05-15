module Wrath
  # Volcano god for the island level.
  class Volcano < God

    def on_disaster_start(sender)
       LavaRock.create(position: rock_spawn_position)
    end

    def update
      super

      if in_disaster?
        intensity = Math::log(@num_disasters * 100)

        if not parent.client? and rand(100) < ((intensity * parent.frame_time) / 8000)
          LavaRock.create(position: rock_spawn_position)
        end
      end
    end

    def rock_spawn_position
      margin = parent.class::Margin
      [
        margin::LEFT + rand($window.retro_width - margin::LEFT - margin::RIGHT),
        margin::TOP + rand($window.retro_height - margin::TOP - margin::BOTTOM),
        $window.retro_height
      ]
    end
  end
end