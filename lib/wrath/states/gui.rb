class Gui < Fidgit::GuiState
  def initialize
    super

    self.cursor.image = Image["cursor_6x6.png"]
    self.cursor.factor = $window.sprite_scale
  end

  def draw
    $window.scale(1.0 / $window.sprite_scale) { super }
  end
end