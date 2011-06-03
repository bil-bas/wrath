module Gosu
  class Sample
    DEFAULT_VOLUME = 1.0

    class << self
      # Volume of all Samples.
      attr_reader :volume

      # Volume of Samples, affected by Sample and Window volume and muting.
      def effective_volume
        @volume * $window.effective_volume
      end

      def volume=(value)
        raise "Bad volume setting" unless value.is_a? Numeric

        @volume = [[value, 1.0].min, 0.0].max.to_f
      end

      def init_sound
        @volume = DEFAULT_VOLUME
        nil
      end
    end

    init_sound

    attr_reader :volume

    alias_method :old_initialize, :initialize
    protected :old_initialize
    public
    def initialize(filename, options = {})
      options = {
          volume: DEFAULT_VOLUME,
      }.merge! options

      @volume = options[:volume]

      old_initialize(filename)
    end

    def volume=(value)
      raise "Bad volume setting" unless value.is_a? Numeric

      @volume = [[value, 1.0].min, 0.0].max.to_f
    end

    public
    def effective_volume
      @volume * self.class.effective_volume
    end

    alias_method :old_play, :play
    protected :old_play
    public
    def play(volume = 1, speed = 1, looping = false)
      volume *= effective_volume
      old_play(volume, speed, looping) if volume > 0.0
    end

    alias_method :old_play_pan, :play_pan
    protected :old_play_pan
    public
    def play_pan(pan = 0, volume = 1, speed = 1, looping = false)
      volume *= effective_volume
      old_play_pan(pan, volume, speed, looping) if volume > 0.0
    end
  end
end