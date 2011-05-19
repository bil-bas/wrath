module Wrath
  class Message
    # Remove a status effect from a particular object.
    class RemoveStatus < Message
      public
      def initialize(object, status)
        @id, @type = object.id, status.type
      end

      protected
      def action(state)
        object = object_by_id(@id)
        if object and object.valid_status?(@type)
          object.remove_status(@type)
        else
          log.error { "Failed to find object ##{@id} to remove status #{@type}" }
        end
      end
    end
  end
end