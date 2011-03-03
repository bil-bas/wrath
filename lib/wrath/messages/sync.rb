class Message
  # Synchronise state: position and velocity.
  class Sync < Message
    def initialize(object)
      @id = object.id
      @position = object.position
      @velocity = object.velocity
    end

    def process
      object = find_object_by_id(@id)
      if object
        object.sync(@position, @velocity)
      else
        puts "Could not sync object ##{@id}"
      end
    end
  end
end