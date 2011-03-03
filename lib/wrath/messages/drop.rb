class Message
  # Drop the object carried by a creature.
  class Drop < Message
    def initialize(actor)
      @actor_id = actor.id
    end

    def process
      find_object_by_id(@actor_id).drop
    end
  end
end