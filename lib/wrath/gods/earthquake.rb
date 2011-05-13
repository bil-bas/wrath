module Wrath
  # Earthquake god for the dungeon level.
  class Earthquake < God
    attr_reader :quake_offset

    def disaster_duration; 1000 + 100 * @num_disasters; end

    def setup
      @quake_offset = 0
    end

    def on_disaster(sender)
      Sample["objects/rock_sacrifice.wav"].play
    end

    def update
      super

      if @disaster_duration > 0
        intensity = Math::log(@num_disasters * 100)
        @quake_offset = intensity / 4

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
        margin::LEFT + rand($window.width - margin::LEFT - margin::RIGHT),
        margin::TOP + rand($window.height - margin::TOP - margin::BOTTOM),
        $window.height
      ]
    end
  end
end