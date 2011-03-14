module Wrath
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
        log.error { "Could not sync object ##{@id}" }
      end
    end

    # Optimise dump to produce little data, since this data is sent very often.
    def marshal_dump
      [@id, @position, @velocity]
    end

    def marshal_load(attributes)
      @id, @position, @velocity = attributes
    end
  end
end
end