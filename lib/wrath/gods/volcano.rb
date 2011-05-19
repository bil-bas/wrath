module Wrath
  # Volcano god for the island level.
  class Volcano < God
    def loved_objects; [Pirate, Amazon, Monkey, Parrot, TreasureChest]; end

    def update
      super

      if in_disaster?
        intensity = Math::log(@num_disasters * 100)

        if not parent.client? and rand(100) < ((intensity * parent.frame_time) / 8000)
          LavaRock.create(position: spawn_position($window.retro_height))
        end
      end
    end
  end
end