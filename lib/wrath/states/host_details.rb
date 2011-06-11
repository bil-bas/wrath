module Wrath
  class HostDetails < NetworkDetails
    def body
      grid num_columns: 2, padding: 0 do
        name_entry
        port_entry
      end
    end

    def extra_buttons
      button t.button.host.text, shortcut: :auto do
        settings[:player, :name] = @player_name.text
        push_game_state Server.new(port: @port.text.to_i)
      end
    end
  end
end