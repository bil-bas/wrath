module Wrath
  class Play < Gui
    BUTTONS = [:offline, :join, :host]

    def body
      BUTTONS.each do |name|
        button(t.button[name].text, icon: Image["gui/play_#{name}.png"], width: 87, shortcut: :auto, tip: t.button[name].tip) { send("#{name}_game") }
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