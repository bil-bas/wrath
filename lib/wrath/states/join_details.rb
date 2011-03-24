module Wrath
  class JoinDetails < NetworkDetails
    def initialize
      super

      pack :vertical, spacing: 32 do
        pack :grid, num_columns: 2, spacing: 16 do
          name_entry

          label "Host address"
          @address = text_area text: settings[:network, :address], max_height: 30, width: $window.width / 2

          port_entry
        end

        button("Connect") do
          settings[:player, :name] = @player_name.text
          push_game_state Client.new(address: @address.text, port: @port.text.to_i)
        end
      end
    end
  end
end