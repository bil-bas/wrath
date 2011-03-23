module Wrath
  class Message
    class Disaster < Message
      protected
      def action(state)
        state.disaster
      end
    end
  end
end
