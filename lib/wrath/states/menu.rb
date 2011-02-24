class Menu < Chingu::GameState
  def initialize
    super

    menu_items = {
      "Local Game" => Play,
      "Join Game" => Client,
      "Host Game" => Server,
      "Exit" => :exit,
    }

    add_inputs(
        l: Play,
        j: Client,
        h: Server,
        e: :exit,
        escape: :exit
    )

    SimpleMenu.create(spacing: 15, x: 80, y: 60, menu_items: menu_items, size: 14)
  end
end
