module Wrath
  class Message
    class UpdateLobby < Message
      public
      def initialize(type, *data)
        @type, @data = type, data
      end

      protected
      def action(state)
        case @type
          when :player
            player_number, priest_index = @data
            raise "Bad player_number update data: #{player_number}" unless player_number.is_a? Fixnum
            raise "Bad priest_index update data: #{priest_index}" unless priest_index.is_a? Fixnum
            state.update_player player_number, priest_index

          when :level
            level = @data[0]
            raise "Bad level update data: #{level}" unless level != Play and level.ancestors.include? Play
            state.update_level level

          when :ready
            player_number, value = @data
            raise "Bad player_number update data: #{player_number}" unless player_number.is_a? Fixnum
            raise "Bad ready update data: #{value}" unless [true, false].include? value
            state.update_ready player_number, value

          else
            raise "Unrecognised lobby update, #{@type}"
        end
      end
    end
  end
end