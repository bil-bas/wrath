# Standard libs
require 'forwardable'
require 'yaml'
require 'fileutils'

# Gems
require 'chingu'
require 'texplay'
require 'chipmunk'

begin
  # If this isn't the exe, allow dropping into a pry session.
  unless defined? Ocra
    require 'pry'
    require 'win32console'
  end
rescue LoadError
end

include Gosu
include Chingu

RequireAll.require_all File.dirname(__FILE__)

Gosu::Sample.volume = 0.5

module Wrath
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

# Copy default config files, if they are not already available.
config_dir = File.join(ROOT_PATH, 'config')
FileUtils.mkdir_p config_dir
Dir[File.join(File.dirname(__FILE__), 'default_config', '*.yml')].each do |config_file|
  unless File.exists?(File.join(config_dir, File.basename(config_file)))
    log.info { "Creating default config file: #{File.basename(config_file)}" }
    FileUtils.cp(config_file, config_dir)
  end
end

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

    @pixel = Image["pixel_1x1.png"]

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

end