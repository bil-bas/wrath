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
        raise "Anger must be a float" unless @anger.is_a? Float
        state.god.anger = @anger
      end

      # Optimise dump to produce little data, since this data is sent very often.
      public
      def marshal_dump; @anger; end
      def marshal_load(data); @anger = data; end
    end
  end
end