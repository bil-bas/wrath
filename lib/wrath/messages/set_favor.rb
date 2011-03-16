module Wrath
  class Message
    class SetFavor < Message
      public
      def initialize(player)
        @player, @favor = player.number, player.favor
      end

      protected
      def action(state)
        state.players[@player].favor = @favor
      end
    end
  end
end