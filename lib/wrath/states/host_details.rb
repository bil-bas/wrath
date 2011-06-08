module Wrath
  class HostDetails < NetworkDetails
    def initialize
      super

      vertical do
        label t.title, font_size: 32

        grid num_columns: 2, padding: 0 do
          name_entry
          port_entry
        end

        horizontal padding: 0 do
          button shortcut(t.button.back.text) do
            pop_game_state
          end

          button shortcut(t.button.host.text) do
            settings[:player, :name] = @player_name.text
            push_game_state Server.new(port: @port.text.to_i)
          end
        end
      end
    end
  end
end