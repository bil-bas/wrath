module Wrath
  class Play < Gui
    BUTTONS = [:offline, :join, :host]

    def initialize
      super

      BUTTONS.each do |name|
        on_input(t.button[name].text[0].downcase.to_sym) { send("#{name}_game")}
      end

      vertical do
        label t.title, font_size: 32

        vertical padding: 0, spacing: 10 do
          BUTTONS.each do |name|
            button(shortcut(t.button[name].text), icon: icon(name), width: 320, tip: t.button[name].tip) { send("#{name}_game") }
          end
        end

        horizontal padding: 0 do
          button(shortcut(t.button.back.text)) { pop_game_state }
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