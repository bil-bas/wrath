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

begin
  require 'bundler/setup' unless defined?(OSX_EXECUTABLE) or ENV['OCRA_EXECUTABLE']

rescue LoadError
  $stderr.puts "Bundler gem not installed. To install:\n  gem install bundler"
  exit
rescue Exception
  $stderr.puts "Gem dependencies not met. To install:\n  bundle install"
  exit
end

require 'gosu'
require 'chingu'
require 'texplay'
require 'fidgit'
require 'chipmunk'
require 'r18n-desktop'

begin
  # If this isn't the exe, allow dropping into a pry session.
  unless defined? Ocra or defined? OSX_EXECUTABLE
    require 'pry'
  end
rescue LoadError
end

TexPlay.set_options(caching: false)

include Gosu
include Chingu


RequireAll.require_all File.dirname(__FILE__)

Fidgit::Element.schema.merge_schema! YAML.load(File.read(File.join(EXTRACT_PATH, 'config', 'schema.yml')))

module Wrath

LANG_DIR = File.join(EXTRACT_PATH, 'config/lang')

# Objects within a collision group will never collide with each other.
module CollisionGroup
  STATIC = 1 # statics and walls
  PARTICLE = 2 # particles
end

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

  FONT = "04B_03__.TTF"

  REAL_WIDTH, REAL_HEIGHT = 192, 120 # Actual rendering size.

  SETTINGS_CONFIG_FILE = 'settings.yml' # The general settings file.
  STATISTICS_CONFIG_FILE = 'statistics.yml'
  CONTROLS_CONFIG_FILE = 'controls.yml'
  ACHIEVEMENTS_CONFIG_FILE = 'achievements.yml'

  ACHIEVEMENTS_DEFINITION_FILE = File.join(EXTRACT_PATH, 'config/achievement_definitions.yml')

  @@settings = Settings.new(SETTINGS_CONFIG_FILE)
  @@controls = Settings.new(CONTROLS_CONFIG_FILE)
  @@statistics = Settings.new(STATISTICS_CONFIG_FILE, auto_save: false)
  def self.settings; @@settings; end
  def self.controls; @@controls; end
  def self.statistics; @@statistics; end
  def settings; self.class.settings; end
  def controls; self.class.controls; end
  def statistics; self.class.statistics; end

  attr_reader :pixel, :sprite_scale, :achievement_manager, :potential_fps

  # Fudge to allow TexPlay's render_to_image to work!
  def unretro(&block)
    @retro_sizing = false
    yield
    @retro_sizing = true
  end
  def width; @retro_sizing ? @width : super; end
  def height; @retro_sizing ? @height : super; end

  def t; R18n.get.t.game; end

  def initialize
    @error_message = nil
    @retro_sizing = true
    @width, @height = REAL_WIDTH, REAL_HEIGHT

    full_screen = settings[:video, :full_screen]
    if full_screen
      # Run at desktop resolution; saves infinite headaches!
      width, height = [screen_width, screen_height]
      @sprite_scale = [width / REAL_WIDTH.to_f, height / REAL_HEIGHT.to_f].min
      @effective_width, @effective_height = @width * @sprite_scale, @height * @sprite_scale
      @correct_aspect = (@effective_width == screen_width) and (@effective_height == screen_height)
      unless @correct_aspect
        @offset_x = (screen_width - @effective_width) / 2
        @offset_y = (screen_height - @effective_height) / 2
      end
    else
      # Run in a window at an integer scaling up factor.
      @sprite_scale = settings[:video, :window_scale]
      width, height = [REAL_WIDTH * @sprite_scale, REAL_HEIGHT * @sprite_scale]
      @effective_width, @effective_height = width, height
      @correct_aspect = true
    end

    Font.factor_stored = @sprite_scale
    Font.factor_rendered = 1.0 / @sprite_scale

    log.info { "Opened window at #{width}x#{height} (X#{@sprite_scale} zoom)" }

    super(width, height, full_screen)

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
    @fps_overlay = nil

    log.info "Reading sound settings"
    self.volume = settings[:audio, :master_volume]
    mute if settings[:audio, :muted]
    Sample.volume = settings[:audio, :effects_volume]
    Song.volume = settings[:audio, :music_volume]

    self.caption = "Loading..."

    push_game_state Preload
  end

  public
  # Extra init called from the pre-load state, that isn't immediately required..
  def preload_init
    @pixel = TexPlay.create_image($window, 1, 1, color: :white) # Used to draw with.

    # Load up locales.
    RequireAll.require_all File.join(LANG_DIR, 'locales')
    R18n.from_env LANG_DIR, @@settings[:locale]

    log.info "Reading achievement/stats"
    @achievement_manager = AchievementManager.new(ACHIEVEMENTS_DEFINITION_FILE, ACHIEVEMENTS_CONFIG_FILE, @@statistics)
    add_overlay AchievementOverlay.new(@achievement_manager)

    options_changed
  end

  def options_changed
    R18n.from_env LANG_DIR, settings[:locale]

    # If locale has changed, then title may have changed too.
    self.caption = t.title

    state = game_state_manager.current_game_state
    state.finalize if state.respond_to? :finalize
    state.setup if state.respond_to? :setup

    on_input(controls[:general, :toggle_fps]) do
      if @fps_overlay
        remove_overlay @fps_overlay
        @fps_overlay = nil
      else
        @fps_overlay = FPSOverlay.new
        add_overlay @fps_overlay
      end
    end
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
    if @error_message
      begin
        font_size = 4
        @error_font ||= Font.new(self, default_font_name, font_size)
        @error_message.each_line.with_index do |line, i|
          @error_font.original_draw line.strip, @sprite_scale, @sprite_scale + (i * font_size * @sprite_scale), 0
        end
      rescue => ex
      end
    else
      begin
        draw_started = milliseconds

        # Draw sprites at the retrofied scale. If in full-screen at an odd aspect ratio, then cry.
        if @correct_aspect
          scale(@sprite_scale) { super }
        else
          translate(@offset_x, @offset_y) do
            clip_to(0, 0, width, height) do
              scale(@sprite_scale) { super }
            end
          end
        end

        @used_time += milliseconds - draw_started

        @overlays.each {|o| o.draw if o.visible? }

      rescue => ex
         handle_error('draw', ex)
      end
    end
  end

  def update
    return if @error_message

    update_started = milliseconds

    @overlays.each(&:update_trait)
    @overlays.each(&:update)

    super

    @used_time += milliseconds - update_started

    recalculate_cpu_load
  rescue => ex
    handle_error('update', ex)
  end

  # Ensure that all Gosu call-backs catch errors properly.
  %w(needs_redraw? needs_cursor? lose_focus button_down button_up).each do |callback|
    define_method callback do |*args|
      return false if @error_message

      begin
        super(*args)
      rescue => ex
        handle_error(callback, ex)
      end
    end
  end

  def handle_error(where, exception)
    begin
      @error_message =<<TEXT
<c=ff0000><b>Fatal error occurred in #{self.class}##{where}</b></c>

Full log written to: #{LOG_FILE ? "\n<i>  #{LOG_FILE}</i>" : 'console' }
Please send the log to Spooner at bil.bagpuss@gmail.com - Thanks!

#{exception.class}: #{exception.message}
#{exception.backtrace.join("\n")}
TEXT

      game_state_manager.clear_game_states
      log.error @error_message

    rescue
      # Ignore errors in this bit.
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