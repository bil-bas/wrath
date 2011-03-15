module Wrath
  class Message
    class SetHealth < Message
      def initialize(creature)
        @creature_id, @health = creature.id, creature.health
      end

      public
      def process
        creature = object_by_id(@creature_id)
        if creature
          creature.health = @health
        else
          log.warn { "Failed to set health for creature##{@creature_id} to #{value}" }
        end
      end
    end
  end
end