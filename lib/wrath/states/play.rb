module Wrath
  class Play < Gui
    BUTTONS = [:offline, :join, :host]

    def initialize
      super

      vertical do
        label t.title, font_size: 32

        vertical padding: 0, spacing: 10 do
          BUTTONS.each do |name|
            button(t.button[name].text, icon: icon(name), width: 320, shortcut: true, tip: t.button[name].tip) { send("#{name}_game") }
          end
        end

        horizontal padding: 0 do
          button(t.button.back.text, shortcut: true) { pop_game_state }
        end
      end
    end

    def icon(type)
      ScaledImage.new(Image["gui/play_#{type}.png"], $window.sprite_scale)
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