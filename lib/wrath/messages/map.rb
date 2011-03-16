module Wrath
  class Message
    class Map < Message

      public
      def initialize(tiles)
        @tiles = tiles
      end

      protected
      def action(state)
        state.create_map(@tiles)
      end
    end
  end
end