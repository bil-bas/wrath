module Wrath
  class Message
    # An object has stopped moving.
    class Stop < Message
      public
      def initialize(actor)
        @id = actor.id
      end

      protected
      def action(state)
        actor = object_by_id(@id)
        if actor
          actor.stop
        else
          log.error { "Failed to make object ##{@id} stop" }
        end
      end
    end
  end
end