module Wrath
  # Cosmic evil.
  class Azathoth < God
    def loved_objects; [Pirate, Amazon, Monkey, Parrot, TreasureChest]; end

    def update
      super

      if in_disaster?
        if not parent.client? and rand(100) < ((1000 * parent.frame_time) / 8000)
          Meteorite.create(position: spawn_position($window.retro_height), parent: parent)
        end
      end
    rescue Exception => e
      log.debug e
    end
  end
end