module Wrath
class Message
  # Synchronise state: position and velocity.
  class Sync < Message
    def initialize(object)
      @id = object.id
      @data = object.sync_data
    end

    def process
      object = object_by_id(@id)
      if object
        object.sync(*@data)
      else
        log.error { "#{self.class} could not sync object ##{@id}" }
      end
    end

    # Optimise dump to produce little data, since this data is sent very often.
    def marshal_dump
      [@id, @data]
    end

    def marshal_load(attributes)
      @id, @data = attributes
    end
  end
end
end