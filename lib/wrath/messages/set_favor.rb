module Wrath
  class Message
    class SetFavor < Message
      def initialize(player)
        @player, @favor = player.number, player.favor
      end

      public
      def process
        $window.current_game_state.players[@player].favor = @favor
      end
    end
  end
end