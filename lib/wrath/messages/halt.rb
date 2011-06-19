module Wrath
  class Message
    # An object has stopped moving.
    class Halt < Message
      public
      def initialize(object)
        @id, @position = object.id, object.position
      end

      protected
      def action(state)
        object = object_by_id(@id)

        if object
          if @position.size == 3 and @position.all? {|i| i.is_a? Numeric }
            object.halt(@position)
          else
            log.error { "Bad position #{@position}" }
          end
        else
          log.error { "Failed to find object ##{@id} to make it halt" }
        end
      end
    end
  end
end