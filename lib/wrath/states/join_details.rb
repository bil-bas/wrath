module Wrath
  class JoinDetails < NetworkDetails
    def setup
      super

      vertical do
        label t.title, font_size: 32

        grid num_columns: 2, padding: 0 do
          name_entry

          label t.label.address
          @address = text_area text: settings[:network, :address], max_height: 30, width: $window.width / 2

          port_entry
        end

        horizontal padding: 0 do
          button t.button.back.text, shortcut: :auto do
            pop_game_state
          end

          button t.button.join.text, shortcut: :auto do
            settings[:player, :name] = @player_name.text
            push_game_state Client.new(address: @address.text, port: @port.text.to_i)
          end
        end
      end
    end
  end
end