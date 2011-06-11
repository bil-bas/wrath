module Wrath
  # Cosmic evil.
  class Azathoth < God
    def update
      super

      if in_disaster?
        if not parent.client? and rand(100) < ((1000 * parent.frame_time) / 8000)
          Meteorite.create(position: spawn_position($window.height), parent: parent)
        end
      end
    end
  end
end