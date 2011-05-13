module Wrath
  class Message
    # A creature has been knocked over by a another object.
    class KnockedDown < Message
      public
      def initialize(knocked, knocker)
        @knocked_id, @knocker_id = knocked.id, knocker.id
      end

      protected
      def action(state)
        knocker, knocked = object_by_id(@knocker_id), object_by_id(@knocked_id)
        if knocker and knocked
          knocked.knocked_down_by knocker
        else
          log.error { "#{self.class} failed to knock down object ##{@knocked_id} with ##{@knocker_id}" }
        end
      end
    end
  end
end