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
            player_number, priest_name = @data
            raise "Bad player_number update data: #{player_number}" unless player_number.is_a? Fixnum
            raise "Bad priest_index update data: #{priest_index}" unless Priest::NAMES.include? priest_name
            state.update_player player_number, priest_name

          when :level
            level = @data[0]
            raise "Bad level update data: #{level}" unless level != Level and level.ancestors.include? Level
            state.update_level level

          when :god
            god = @data[0]
            raise "Bad god update data: #{god}" unless god != God and god.ancestors.include? God
            state.update_god god

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