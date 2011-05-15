module Wrath
  class Message
    # Synchronise the anger of the god.
    class SetAnger < Message
      public
      def initialize(god)
        @anger = god.anger
      end

      protected
      def action(state)
        state.god.anger = @anger
      end
    end
  end
end