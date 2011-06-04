# Standard libs
require 'forwardable'
require 'yaml'
require 'fileutils'
require 'logger'

# Gems
begin
  require 'rubygems' unless defined? OSX_EXECUTABLE
rescue LoadError
end

require 'bundler/setup' unless defined? OSX_EXECUTABLE

require 'chingu'
require 'texplay'
require 'fidgit'
require 'chipmunk'

begin
  # If this isn't the exe, allow dropping into a pry session.
  unless defined? Ocra or defined? OSX_EXECUTABLE
    require 'pry'
  end
rescue LoadError
end

include Gosu
include Chingu

RequireAll.require_all File.dirname(__FILE__)

SCHEMA_FILE = File.join(EXTRACT_PATH, 'lib', 'wrath', 'schema.yml')
Fidgit::Element.schema.merge_schema! YAML.load(File.read(SCHEMA_FILE))




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

  RETRO_WIDTH = 192
  RETRO_HEIGHT = 120

  SETTINGS_CONFIG_FILE = 'settings.yml' # The general settings file.
  STATISTICS_CONFIG_FILE = 'statistics.yml'
  CONTROLS_CONFIG_FILE = 'controls.yml'
  ACHIEVEMENTS_CONFIG_FILE = 'achievements.yml'

  TITLE = "-=- Wrath: Appease or Die! -=- by Spooner -=-"

  @@settings = Settings.new(SETTINGS_CONFIG_FILE)
  @@controls = Settings.new(CONTROLS_CONFIG_FILE)
  @@statistics = Settings.new(STATISTICS_CONFIG_FILE, auto_save: false)
  def self.settings; @@settings; end
  def self.controls; @@controls; end
  def self.statistics; @@statistics; end
  def settings; self.class.settings; end
  def controls; self.class.controls; end
  def statistics; self.class.statistics; end

  attr_reader :pixel, :sprite_scale, :achievement_manager

  def retro_width; RETRO_WIDTH; end
  def retro_height; RETRO_HEIGHT; end

  def initialize
    full_screen = false # settings[:video, :full_screen]

    @sprite_scale = settings[:video, :window_scale]

    width, height = if full_screen
                      [screen_width, screen_height]
                    else
                      [RETRO_WIDTH * @sprite_scale, RETRO_HEIGHT * @sprite_scale]
                    end

    log.info { "Opened window at #{width}x#{height} (X#{@sprite_scale} zoom)" }

    super(width, height, full_screen)
  end

  # To change
  def setup
    media_dir = File.expand_path(File.join(EXTRACT_PATH, 'media'))
    Image.autoload_dirs.unshift File.join(media_dir, 'images')
    Sample.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Song.autoload_dirs.unshift File.join(media_dir, 'music')
    Font.autoload_dirs.unshift File.join(media_dir, 'fonts')

    retrofy

    @used_time = 0
    @last_time = milliseconds
    @potential_fps = 0
    @overlays = []

    @pixel = TexPlay.create_image($window, 1, 1, color: :white) # Used to draw with.

    log.info "Reading achievement/stats"
    @achievement_manager = AchievementManager.new(ACHIEVEMENTS_CONFIG_FILE, @@statistics)    
    add_overlay AchievementOverlay.new(@achievement_manager)

    log.info "Reading sound settings"
    self.volume = settings[:audio, :master_volume]
    mute if settings[:audio, :muted]
    Sample.volume = settings[:audio, :effects_volume]
    Song.volume = settings[:audio, :music_volume]

    push_game_state Menu
  end

  def add_overlay(overlay)
    @overlays << overlay
    overlay
  end

  def remove_overlay(overlay)
    @overlays.delete overlay
    overlay
  end

  def draw
    draw_started = milliseconds

    # Draw sprites at the retrofied scale.
    scale(@sprite_scale) do
      super
    end

    @used_time += milliseconds - draw_started
    
    @overlays.each(&:draw)
  rescue => ex
    log.error "#draw: #{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}"
    raise ex
  end

  def update
    update_started = milliseconds
    
    @overlays.each(&:update)

    super

    self.caption = "#{TITLE} [FPS: #{fps} (#{@potential_fps})]"

    @used_time += milliseconds - update_started

    recalculate_cpu_load
  rescue => ex
    log.error "#update: #{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}"
    raise ex
  end

  # Ensure that all Gosu call-backs catch errors properly.
  %w(needs_redraw? needs_cursor? lose_focus button_down button_up).each do |callback|
    define_method callback do |*args|
      begin
        super(*args)
      rescue => ex
        log.error "##{callback}: #{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}"
        raise ex
      end
    end
  end

  def recalculate_cpu_load
    if (milliseconds - @last_time) >= 1000
      @potential_fps = (fps / [(@used_time.to_f / (milliseconds - @last_time)), 0.0001].max).floor
      @used_time = 0
      @last_time = milliseconds
    end
  end

  def self.run
    new.show
  end
end

end