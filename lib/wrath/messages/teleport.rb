module Wrath
  class Message
    # Teleport between portals.
    class Teleport < Message
      public
      def initialize(actor, destination)
        @actor_id, @destination_id = actor.id, destination.id
      end

      protected
      def action(state)
        actor = object_by_id(@actor_id)
        destination = object_by_id(@destination_id)
        if actor and destination and destination.respond_to? :teleport
          destination.teleport(actor)
        else
          log.error { "Failed to make object ##{@actor_id} teleport to ##{@destination_id}" }
        end
      end
    end
  end
end