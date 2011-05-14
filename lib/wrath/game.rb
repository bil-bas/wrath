# Standard libs
require 'forwardable'
require 'yaml'
require 'fileutils'
require 'logger'

# Gems
begin
  require "rubygems"
rescue LoadError
end

require "bundler/setup"

require 'chingu'
require 'texplay'
require 'fidgit'
require 'chipmunk'

SCHEMA_FILE = File.join(EXTRACT_PATH, 'lib', 'wrath', 'schema.yml')


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

Fidgit::Element.schema.merge_elements! YAML.load(File.read(SCHEMA_FILE))

module Wrath
module ZOrder
  BACKGROUND = -Float::INFINITY
  TILES = -3
  SHADOWS = -2
  BACK_GLOW = -1
  OBJECTS = 0..640
  FOREGROUND = 999999
  GUI = Float::INFINITY
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
    @sprite_scale = 4

    @used_time = 0
    @last_time = milliseconds
    @potential_fps = 0

    @pixel = Image["objects/pixel_1x1.png"] # Used to draw with.

    push_game_state Menu
  end


  def draw
    draw_started = milliseconds

    # Draw sprites at the retrofied scale.
    scale(@sprite_scale) do
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