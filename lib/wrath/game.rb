# Standard libs
require 'forwardable'
require 'yaml'
require 'fileutils'
require 'logger'

# Gems
require 'C:\Users\Spooner\RubymineProjects\chingu\lib\chingu'
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

# Copy default config files, if they are not already available.
config_dir = File.join(ROOT_PATH, 'config')
FileUtils.mkdir_p config_dir
Dir[File.join(File.dirname(__FILE__), 'default_config', '*.yml')].each do |config_file|
  unless File.exists?(File.join(config_dir, File.basename(config_file)))
    Log.log.info { "Creating default config file: #{File.basename(config_file)}" }
    FileUtils.cp(config_file, config_dir)
  end
end

class Game < Window
  include Log

  SIZE = [768, 480]

  TITLE = "=== Wrath! === Appease the gods or suffer the consequences..."
  attr_reader :pixel, :sprite_scale

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

    @used_time = 0
    @last_time = milliseconds
    @potential_fps = 0

    @pixel = Image["pixel_1x1.png"]

    push_game_state Menu
  end


  def draw
    draw_started = milliseconds

    # Draw sprites at the retrofied scale.
    scale(@sprite_scale, @sprite_scale) do
      super
    end

    @used_time += milliseconds - draw_started
  end

  def update
    update_started = milliseconds

    super

    self.caption = "#{TITLE} [FPS: #{fps} (#{@potential_fps})]"

    @used_time += milliseconds - update_started

    recalculate_cpu_load
  end

  def recalculate_cpu_load
    if (milliseconds - @last_time) >= 1000
      @potential_fps = (fps / [(@used_time.to_f / (milliseconds - @last_time)), 0.0001].max).floor
      @used_time = 0
      @last_time = milliseconds
    end
  end

  def self.run
    new(*SIZE, false).show
  end
end

end