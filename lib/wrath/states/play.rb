module Wrath
  class Play < Gui
    BUTTONS = [:offline, :join, :host]

    def setup
      super

      vertical do
        label t.title, font_size: 8

        vertical padding: 0, spacing: 2.5 do
          BUTTONS.each do |name|
            button(t.button[name].text, icon: Image["gui/play_#{name}.png"], width: 87, shortcut: :auto, tip: t.button[name].tip) { send("#{name}_game") }
          end
        end

        horizontal padding: 0 do
          button(t.button.back.text, shortcut: :auto) { pop_game_state }
        end
      end
    end

    def offline_game
      push_game_state Lobby.new(nil, "Player2",  "Player1")
    end

    def join_game
      push_game_state JoinDetails
    end

    def host_game
      push_game_state HostDetails
    end
  end
end