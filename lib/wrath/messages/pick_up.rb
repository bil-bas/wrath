class Message
  # Pick up the object from teh ground.
  class PickUp < Message
    value :actor, nil
    value :object, nil

    def process
      find_object_by_id(actor).pick_up(find_object_by_id(object))
    end
  end
end