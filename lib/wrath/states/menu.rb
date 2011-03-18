module Wrath
class Menu < Chingu::GameState
  def initialize
    super

    menu_items = {
      "Local Game" => ->{ push_game_state(Lobby.new(nil, "Player2",  "Player1")) },
      "Join Game" => EnterServerIP,
      "Host Game" => Server,
      "Exit" => :close,
    }

    add_inputs(
        l: Play,
        j: EnterServerIP,
        h: Server,
        e: :close,
        escape: :close
    )

    Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

    center = $window.retro_width / 2
    SimpleMenu.create(spacing: 3, x: center, y: 43, menu_items: menu_items, size: 14)
    Text.create("Wrath!", x: center, y: 5, rotation_center: :top_center, size: 20, factor: 2, color: Color.rgb(0, 100, 0))
  end

  def setup
    log.info "Viewing main menu"
  end

  def close
    log.info "Exited game"
    super
    exit
  end
end
end
