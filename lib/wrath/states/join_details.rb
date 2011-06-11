module Wrath
  class JoinDetails < NetworkDetails
    def body
      grid num_columns: 2, padding: 0 do
        name_entry

        label t.label.address
        @address = text_area TEXT_ENTRY_OPTIONS.merge(text: settings[:network, :address])

        port_entry
      end
    end

    def extra_buttons
      button t.button.join.text, shortcut: :auto do
        settings[:player, :name] = @player_name.text
        push_game_state Client.new(address: @address.text, port: @port.text.to_i)
      end
    end
  end
end