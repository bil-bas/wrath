class Message
  # Drop the object carried by a creature.
  class Drop < Message
    value :actor, nil

    def process
      find_object_by_id(actor).drop
    end
  end
end