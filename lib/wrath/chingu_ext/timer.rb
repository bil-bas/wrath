module Chingu
  module Traits
    module Timer
      def timer_time_remaining(name)
        timer = @_timers.find { |nom, | nom == name }
        if timer
          Gosu::milliseconds - timer[1]
        else
          0
        end
      end
    end
  end
end