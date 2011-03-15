module Wrath
  class Message
    class SetFavor < Message
      def initialize(player)
        @player, @favor = player.number, player.favor
      end

      public
      def process
        state = $window.current_game_state
        if state.is_a? Play
          state.players[@player].favor = @favor
        end
      end
    end
  end
end