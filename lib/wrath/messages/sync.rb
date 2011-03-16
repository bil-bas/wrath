module Wrath
class Message
  # Synchronise state for all dynamic objects: position and velocity.
  class Sync < Message
    ACCURACY = 10.0 ** 3.0 # Accurate to 3 decimal places.
    SEPARATOR = ';'

    def initialize(objects)
      @data = objects.inject([]) do |data, object|
        # id=42, position=[1.9999999999, 1.12345, 1.9], velocity=[2.9999999999, 2.9999999, 2.0]]
        # # => "42;2;1.123;1.9;3;3;2"
        datum = [object.position, object.velocity].flatten
        datum.map! do |n|
          n = (n * ACCURACY).round / ACCURACY # Reduce decimal places.
          (n == n.to_i) ? n.to_i : n
        end

        data << ([object.id] + datum).join(SEPARATOR)
      end
    end

    def process
      @data.each do |data|
        data = data.split(SEPARATOR)
        id, position, velocity = data[0].to_i, data[1..3].map {|n| n.to_f }, data[4..6].map {|n| n.to_f }

        object = object_by_id(id)
        if object
          object.sync(position, velocity)
        else
          log.error { "#{self.class} could not sync object ##{id}" }
        end
      end
    end

    # Optimise dump to produce little data, since this data is sent very often.
    def marshal_dump
      @data
    end

    def marshal_load(data)
      @data = data
    end
  end
end
end