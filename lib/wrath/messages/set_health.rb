module Wrath
  class Message
    class SetHealth < Message
      public
      def initialize(creature)
        @creature_id, @health = creature.id, creature.health
      end

      protected
      def action(state)
        creature = object_by_id(@creature_id)
        if creature
          creature.health = @health
        else
          log.warn { "Failed to set health for creature##{@creature_id} to #{@health}" }
        end
      end
    end
  end
end