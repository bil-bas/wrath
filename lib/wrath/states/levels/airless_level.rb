module Wrath
  class Level < GameState
    # On airless levels, the priests wear cute little helmets.
    class AirlessLevel < Level
      def pushed
        @bubble_helmet = Animation.new(file: "bubble_helmet_10x9.png")
      end

      def draw
        super

        Priest.all.each do |priest|
          if priest.breathes?
            index = case priest.state
                      when :standing, :walking, :mounted  then 0
                      when :lying, :thrown, :carried      then 1
                      else
                        raise "unknown state #{priest.state.inspect}"
                    end

            @bubble_helmet[index].draw_rot priest.x, priest.y - priest.z, priest.zorder + 0.00000001, 0, 0.5, 1.0,
                                           priest.factor_x, priest.factor_y
          end
        end
      end
    end
  end
end