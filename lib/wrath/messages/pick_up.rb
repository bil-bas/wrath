module Wrath
class Message
  # Pick up the object from teh ground.
  class PickUp < Message

    def initialize(actor, object)
      @actor_id, @object_id = actor.id, object.id
    end

    def process
      object_by_id(@actor_id).pick_up(object_by_id(@object_id))
    end
  end
end
end