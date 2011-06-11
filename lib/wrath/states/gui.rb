module Wrath
class Gui < Fidgit::GuiState
  BACKGROUND_COLOR = Color.rgb(0, 0, 75)

  def self.t; R18n.get.t.gui[Inflector.underscore(Inflector.demodulize(name))]; end
  def t; self.class.t; end
  def draw_background?; true; end

  def initialize
    super

    self.cursor.image = Image["gui/cursor.png"]

    create_background

    if t.button.back.text.translated?
      on_input(:escape) { pop_game_state }
    end
  end

  def finalize
    super

    container.clear
  end

  def draw
    @@background_image.draw 0, 0, -Float::INFINITY if draw_background?
    super
  end

  def create_background
    unless defined? @@background_image
      @@background_image = TexPlay.create_image($window, $window.width, $window.height, color: Color.rgb(0, 0, 40))
      $window.render_to_image(@@background_image) do
        color = Color.rgb(220, 220, 255)
        500.times do
          color.alpha = random(75, 125).to_i
          pixel.draw(rand(Game::REAL_WIDTH), rand(Game::REAL_HEIGHT), 0, 1, 1, color)
        end
      end
    end
  end
end
end