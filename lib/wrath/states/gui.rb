class Gui < Fidgit::GuiState
  def initialize
    super

    self.cursor.image = Image["gui/cursor.png"]
    self.cursor.factor = $window.sprite_scale
  end

  def draw
    $window.scale(1.0 / $window.sprite_scale) { super }
  end

  def shortcut(string, shortcut = string[0])
    before, after = string.split(shortcut)
    "#{before}<c=88bbff>#{shortcut}</c>#{after}"
  end
end