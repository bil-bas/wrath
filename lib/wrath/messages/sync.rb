class Message
  # Update status: position and velocity.
  class Sync < Message
    value :id, nil
    value :time, nil
    value :position, nil
    value :velocity, nil

    def process
      object = find_object_by_id(id)
      if object
        find_object_by_id(id).update_status(self)
      else
        puts "Could not update status of object ##{id}"
      end
    end
  end
end