class Gui < Fidgit::GuiState
  def self.t; R18n.get.t.gui[Inflector.underscore(Inflector.demodulize(name))]; end
  def t; self.class.t; end

  def initialize
    super

    self.cursor.image = Image["gui/cursor.png"]
    self.cursor.factor = $window.sprite_scale

    if t.button.back.text.translated?
      on_input(:escape, :pop_game_state)
      on_input(t.button.back.text[0].downcase.to_sym) { pop_game_state unless focus }
    end
  end

  def draw
    $window.scale(1.0 / $window.sprite_scale) { super }
  end

  def shortcut(string, shortcut = string[0])
    before, after = string.split(shortcut)
    "#{before}<c=88bbff>#{shortcut}</c>#{after}"
  end
end