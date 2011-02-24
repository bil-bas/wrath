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
        escape: :exit
    )

    SimpleMenu.create(spacing: 0, y: 0, menu_items: menu_items, size: 16)
    @font = Font[10]
  end

  def draw
    super

    @font.draw("(L)ocal, (J)oin or (H)ost", 0, 0, 0)
  end
end
