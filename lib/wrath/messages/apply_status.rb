module Wrath
  class Message
    # Apply a status effect to a particular object.
    class ApplyStatus < Message
      public
      def initialize(object, status)
        @id, @type = object.id, status.type
      end

      protected
      def action(state)
        object = object_by_id(@id)
        if object and object.valid_status?(@type)
          object.apply_status(@type)
        else
          log.error { "Failed to find object ##{@id} to apply status #{@type}" }
        end
      end
    end
  end
end