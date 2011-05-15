module Wrath
  # Earthquake god for the dungeon level.
  class Earthquake < God
    attr_reader :quake_offset

    def setup
      @quake_offset = 0
    end

    def on_disaster_start(sender)
      Sample["objects/rock_sacrifice.ogg"].play
    end

    def update
      super

      if in_disaster?
        intensity = Math::log(@num_disasters * 100)
        @quake_offset = intensity / 6

        if not parent.client? and rand(100) < ((intensity * parent.frame_time) / 8000)
          Rock.create(position: rock_spawn_position)
        end

        if rand(100) < @num_disasters * 5
          Pebble.create(position: rock_spawn_position)
        end
      else
        @quake_offset = 0
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