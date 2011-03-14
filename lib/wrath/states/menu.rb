module Wrath
class Menu < Chingu::GameState
  def initialize
    super

    menu_items = {
      "Local Game" => Play,
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

    SimpleMenu.create(spacing: 3, x: 80, y: 43, menu_items: menu_items, size: 14)
    Text.create("Wrath!", x: 80, y: 5, rotation_center: :top_center, size: 20, factor: 2, color: Color.rgb(0, 100, 0))
  end

  def setup
    log.info "Viewing main menu"
  end

  def close
    log.info "Exited game"
    super
  end
end
end
