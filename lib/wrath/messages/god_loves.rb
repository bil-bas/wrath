module Wrath
  class Message
    # Change the thing that the gods love.
    class GodLoves < Message
      def initialize(loves)
        @loves = loves
      end

      def action(state)
        if @loves.is_a? Class and @loves.ancestors.include? DynamicObject
          state.god.loves = @loves
        else
          log.error { "#{self.class} with bad love class #{@loves}" }
        end
      end
    end
  end
end