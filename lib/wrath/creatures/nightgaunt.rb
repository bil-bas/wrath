module Wrath
  class Nightgaunt < Humanoid
    MIN_PICK_UP_DELAY = 2500

    def initialize(options = {})
      options = {
          favor: 8,
          move_interval: 0,
          flying_height: 6,
          animation: "nightgaunt_10x9.png",
      }.merge! options
      
      @last_picked_up_at = 0

      super(options)
    end
    
    def on_collision(other)
      if empty_handed? and upright? and not @container and
         (milliseconds - @last_picked_up_at) > MIN_PICK_UP_DELAY and
          other.is_a? Priest and other.can_be_picked_up?(self) and
          not other.inside_container?
        pick_up(other)
        @last_picked_up_at = milliseconds
        false
      else
        super(other)
      end
    end
  end
end