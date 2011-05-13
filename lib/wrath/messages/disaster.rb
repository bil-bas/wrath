module Wrath
  class Message
    class Disaster < Message
      protected
      def action(state)
        state.god.disaster
      end
    end
  end
end
