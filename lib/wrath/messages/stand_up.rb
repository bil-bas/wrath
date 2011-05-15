module Wrath
  class Message
    # A creature that has been knocked down, must eventually get up.
    class StandUp < Message
      public
      def initialize(actor)
        @id = actor.id
      end

      protected
      def action(state)
        actor = object_by_id(@id)
        if actor
          actor.stand_up
        else
          log.error { "Failed to make object ##{@id} get up" }
        end
      end
    end
  end
end