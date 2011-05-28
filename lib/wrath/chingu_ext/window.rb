module Chingu
  class Window
    DEFAULT_VOLUME = 0.5 # Because volume = 1.0 is REALLY loud.

    def volume=(value)
      raise "Bad volume setting" unless value.is_a? Numeric

      old_volume = @volume
      @volume = [[value, 1.0].min, 0.0].max.to_f

      Song.send(:recalculate_volumes, old_volume, @volume)

      volume
    end

    # Volume, not affected by the Window being muted.
    attr_reader :volume

    # Volume, affected by the Window being muted.
    def effective_volume
      muted? ? 0.0 : @volume
    end

    def mute
      unless muted?
        Song.send(:resources).each_value {|song| song.send :mute }
      end
      @times_muted += 1

      self
    end

    def unmute
      raise "Can't unmute when not muted" unless muted?
      @times_muted -= 1
      unless muted?
        Song.send(:resources).each_value {|song| song.send :unmute }
      end

      self
    end

    def muted?
      @times_muted > 0
    end

    alias_method :old_initialize, :initialize
    protected :old_initialize

    def initialize(width, height, full_screen = false, frame_duration = 1000.0/60, options = {})
      options = {
          volume: DEFAULT_VOLUME,
          muted: false,
      }.merge! options

      @volume = options[:volume]
      @times_muted = options[:muted] ? 1 : 0

      old_initialize(width, height, full_screen, frame_duration)
    end
  end
end