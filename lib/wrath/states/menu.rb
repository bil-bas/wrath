module Wrath
class Menu < Gui
  def initialize
    super

    add_inputs(
        l: :local_game,
        j: :join_game,
        h: :host_game,
        e: :close,
        escape: :close
    )

    Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

    pack :vertical, spacing: 32 do
      label "WRATH!", font_size: 120
      pack :vertical, spacing: 12 do
        width = $window.width / 2
        size = 48
        button("Local Game", width: width, font_size: size, tip: 'Play on the same keyboard') { local_game }
        button("Join Game", width: width, font_size: size, tip: 'Connect to a network game someone else is hosting') { join_game }
        button("Host Game", width: width, font_size: size, tip: 'Host a network game that that another player can join') { host_game }
        button("Exit", width: width, font_size: size) { close }
      end
    end
  end

  def setup
    super
    log.info "Viewing main menu"
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

  def close
    log.info "Exited game"
    super
    exit
  end
end
end
