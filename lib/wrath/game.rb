# encoding: utf-8

require 'chingu'
include Gosu
include Chingu

# Objects
require_relative 'local_player'
require_relative 'player'
require_relative 'altar'
require_relative 'goat'

# States
require_relative 'play'
require_relative 'transition'

module ZOrder
  BACKGROUND = -1
  OBJECTS = 0..640
  GUI = 10000
end

class GameObject
  def distance_to(other)
    distance(self.x, self.y, other.x, other.y)
  end
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
  TITLE = "=== Wrath! === Appease the gods or suffer the consequences..."
  attr_reader :character_sprites, :furniture_sprites, :object_sprites, :pixel

  # To change
  def setup
    media_dir = File.expand_path(File.join(ROOT_PATH, 'media'))
    Image.autoload_dirs.unshift File.join(media_dir, 'images')
    Sample.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Song.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Font.autoload_dirs.unshift File.join(media_dir, 'fonts')

    retrofy
    self.factor = 4

    @character_sprites = SpriteSheet.new("char.png", 8, 8, 16)
    @furniture_sprites = SpriteSheet.new("furniture.png", 8, 8, 12)
    @object_sprites = SpriteSheet.new("object.png", 8, 8, 16)

    @pixel = Image["pixel.png"]

    push_game_state Play.new
  end

  def update
    super
    self.caption = "#{TITLE} [#{fps}fps]"
  end

  def self.run
    new(640, 480, false).show
  end
end