module Wrath
  class Message
    class Say < Message
      public
      def initialize(player_number, message)
        @player_number, @message = player_number, message
      end

      protected
      def action(state)
        player = state.player_names[@player_number]

        if player and @message.is_a? String
          state.say(player, @message)
        else
          log.error { "Failed to find player ##{@number} to say #{@message}" }
        end
      end
    end
  end
end