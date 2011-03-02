# encoding: utf-8

require 'chingu'

include Gosu
include Chingu

begin
  require 'pry'
rescue LoadError
end

require 'yaml'

RequireAll.require_all File.join(File.dirname(__FILE__), '**', '*.rb')

module ZOrder
  BACKGROUND = -Float::INFINITY
  TILES = -2
  SHADOWS = -1
  OBJECTS = 0..640
  GUI = 10000
end

class SpriteSheet
  def initialize(file, width, height, tiles_wide)
    @sprites = Image.load_tiles($window, File.join(Image.autoload_dirs[0], file), width, height, false)
    @tiles_wide = tiles_wide
  end

  def [](x, y)
    @sprites[y * @tiles_wide + x]
  end
end

Gosu::Sample.volume = 0.5

class Game < Window
  SIZE = [640, 480]

  TITLE = "=== Wrath! === Appease the gods or suffer the consequences..."
  attr_reader :pixel

  def sprite_scale; @sprite_scale; end
  def retro_width; width / @sprite_scale; end
  def retro_height; height / @sprite_scale; end

  # To change
  def setup
    media_dir = File.expand_path(File.join(EXTRACT_PATH, 'media'))
    Image.autoload_dirs.unshift File.join(media_dir, 'images')
    Sample.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Song.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Font.autoload_dirs.unshift File.join(media_dir, 'fonts')

    retrofy
    @sprite_scale = 4 # 160x120

    @pixel = Image["pixel.png"]

    push_game_state Menu
  end


  def draw
    # Draw sprites at the retrofied scale.
    scale(@sprite_scale, @sprite_scale) do
      super
    end
  end

  def update
    super

    self.caption = "#{TITLE} [#{fps}fps]"
  end

  def self.run
    new(*SIZE, false).show
  end
end