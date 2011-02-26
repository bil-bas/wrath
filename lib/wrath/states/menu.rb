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

    SimpleMenu.create(spacing: 3, x: 80, y: 43, menu_items: menu_items, size: 14)
    Text.create("Wrath!", x: 80, y: 5, rotation_center: :top_center, size: 20, factor: 2, color: Color.rgb(0, 100, 0))
  end
end
