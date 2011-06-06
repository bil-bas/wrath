module Wrath
  class Play < Gui
    def initialize
      super

      add_inputs(
          o: :local_game,
          j: :join_game,
          h: :host_game,
          b: :pop_game_state,
          escape: :pop_game_state
      )

      vertical do
        label "Play Wrath", font_size: 32

        vertical padding: 0, spacing: 10 do
          width = 320
          button("(O)ffline game", icon: icon('offline'), width: width, tip: 'Both players on the same keyboard') { local_game }
          button("(J)oin Game", icon: icon('join'), width: width, tip: 'Connect to a network game someone else is hosting') { join_game }
          button("(H)ost Game", icon: icon('host'), width: width, tip: 'Host a network game that that another player can join') { host_game }
        end

        horizontal padding: 0 do
          button("(B)ack") { pop_game_state }
        end
      end
    end

    def icon(type)
      ScaledImage.new(Image["gui/play_#{type}.png"], $window.sprite_scale)
    end

    def local_game
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