module Wrath
  class HostDetails < NetworkDetails
    def setup
      super

      vertical do
        label t.title, font_size: 8

        grid num_columns: 2, padding: 0 do
          name_entry
          port_entry
        end

        horizontal padding: 0 do
          button t.button.back.text, shortcut: :auto do
            pop_game_state
          end

          button t.button.host.text, shortcut: :auto do
            settings[:player, :name] = @player_name.text
            push_game_state Server.new(port: @port.text.to_i)
          end
        end
      end
    end
  end
end