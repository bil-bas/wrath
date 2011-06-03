module Wrath
  # Earthquake god for the dungeon level.
  class Earthquake < God
    attr_reader :quake_offset

    def self.to_s; "The Earthshaker"; end

    def on_disaster_start(sender)
      Sample["objects/explosion.ogg"].play_at_x(x)
    end

    def update
      super

      if in_disaster?
        intensity = Math::log(@num_disasters * 100)
        parent.screen_offset_y = intensity / 6 * Math::sin(milliseconds / 50.0)

        if not parent.client? and rand(100) < ((intensity * parent.frame_time) / 8000)
          Rock.create(position: spawn_position($window.retro_height), parent: parent)
        end

        if rand(100) < @num_disasters * 5
          Pebble.create(position: spawn_position($window.retro_height), parent: parent)
        end
      else
        @quake_offset = 0
      end
    end
  end
end