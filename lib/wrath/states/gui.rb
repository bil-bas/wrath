class Gui < Fidgit::GuiState
  BACKGROUND_COLOR = Color.rgb(0, 0, 75)

  def self.t; R18n.get.t.gui[Inflector.underscore(Inflector.demodulize(name))]; end
  def t; self.class.t; end

  def initialize
    super

    self.cursor.image = Image["gui/cursor.png"]
    self.cursor.factor = $window.sprite_scale

    if t.button.back.text.translated?
      on_input(:escape) { pop_game_state }
    end

    create_background
  end

  def draw
    @@background_image.draw 0, 0, -Float::INFINITY
    $window.scale(1.0 / $window.sprite_scale) { super }
  end

  def create_background
    unless defined? @@background_image
      @@background_image = TexPlay.create_image($window, $window.retro_width, $window.retro_height, color: Color.rgb(0, 0, 40))
      $window.render_to_image(@@background_image) do
        color = Color.rgb(255, 255, 255)
        500.times do
          color.alpha = 75 + rand(50)
          pixel.draw(rand($window.retro_width), rand($window.retro_height), 0, 1, 1, color)
        end
      end
    end
  end
end