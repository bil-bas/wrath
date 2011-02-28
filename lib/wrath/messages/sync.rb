class Message
  # Synchronise state: position and velocity.
  class Sync < Message
    value :id, nil
    value :time, nil
    value :position, nil # [x, y, z]
    value :velocity, nil # [x, y, z]

    def process
      object = find_object_by_id(id)
      if object
        find_object_by_id(id).sync(self)
      else
        puts "Could not sync object ##{id}"
      end
    end
  end
end