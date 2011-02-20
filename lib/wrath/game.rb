# encoding: utf-8

require 'chingu'
include Gosu
include Chingu

require_relative 'chingu_ext'

# Objects
require_relative 'local_player'
require_relative 'remote_player'
require_relative 'altar'
require_relative 'goat'

# States
require_relative 'server'
require_relative 'client'
require_relative 'menu'
require_relative 'play'
require_relative 'transition'

module ZOrder
  BACKGROUND = -Float::INFINITY
  OBJECTS = 0..640
  GUI = 10000
end

class SpriteSheet
  def initialize(file, width, height, tiles_wide)
    @sprites = Image.load_tiles($window, File.join(Image.autoload_dirs[0], file), width, height, false)
    @tiles_wide = tiles_wide
  end

  def [](x, y)
    @sprites[x * @tiles_wide + y]
  end
end

class Game < Window
  SIZE = [640, 480]

  TITLE = "=== Wrath! === Appease the gods or suffer the consequences..."
  attr_reader :character_sprites, :furniture_sprites, :object_sprites, :pixel

  def sprite_scale; @sprite_scale; end
  def retro_width; width / @sprite_scale; end
  def retro_height; height / @sprite_scale; end

  # To change
  def setup
    media_dir = File.expand_path(File.join(ROOT_PATH, 'media'))
    Image.autoload_dirs.unshift File.join(media_dir, 'images')
    Sample.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Song.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Font.autoload_dirs.unshift File.join(media_dir, 'fonts')

    retrofy
    @sprite_scale = 4 # 160x120

    @character_sprites = SpriteSheet.new("char.png", 8, 8, 16)
    @furniture_sprites = SpriteSheet.new("furniture.png", 8, 8, 12)
    @object_sprites = SpriteSheet.new("object.png", 8, 8, 16)

    @pixel = Image["pixel.png"]

    push_game_state Play
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