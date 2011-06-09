class Gui < Fidgit::GuiState
  def self.t; R18n.get.t.gui[Inflector.underscore(Inflector.demodulize(name))]; end
  def t; self.class.t; end

  def initialize
    super

    self.cursor.image = Image["gui/cursor.png"]
    self.cursor.factor = $window.sprite_scale

    if t.button.back.text.translated?
      on_input(:escape) { pop_game_state }
    end
  end

  def draw
    $window.scale(1.0 / $window.sprite_scale) { super }
  end
end