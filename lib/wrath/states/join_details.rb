module Wrath
  class JoinDetails < NetworkDetails
    def initialize
      super

      vertical do
        label "Joining a Game", font_size: 32

        grid num_columns: 2, padding: 0 do
          name_entry

          label "Host address"
          @address = text_area text: settings[:network, :address], max_height: 30, width: $window.width / 2

          port_entry
        end

        horizontal padding: 0 do
          button shortcut("Back") do
            pop_game_state
          end

          button("Connect") do
            settings[:player, :name] = @player_name.text
            push_game_state Client.new(address: @address.text, port: @port.text.to_i)
          end
        end
      end
    end
  end
end