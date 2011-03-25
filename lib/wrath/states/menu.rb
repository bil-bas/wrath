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

        options = { width: width, font_size: 48, justify: :center }
        button("Local Game", options.merge(tip: 'Play on the same keyboard')) { local_game }
        button("Join Game", options.merge(tip: 'Connect to a network game someone else is hosting')) { join_game }
        button("Host Game", options.merge(tip: 'Host a network game that that another player can join')) { host_game }
        button("Exit", options) { close }
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
