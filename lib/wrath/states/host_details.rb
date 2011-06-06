module Wrath
  class HostDetails < NetworkDetails
    def initialize
      super

      vertical do
        label "Hosting a Game", font_size: 32

        grid num_columns: 2, padding: 0 do
          name_entry
          port_entry
        end

        horizontal padding: 0 do
          button shortcut("Back") do
            pop_game_state
          end

          button("Host") do
            settings[:player, :name] = @player_name.text
            push_game_state Server.new(port: @port.text.to_i)
          end
        end
      end
    end
  end
end