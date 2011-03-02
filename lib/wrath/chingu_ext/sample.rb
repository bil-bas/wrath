module Gosu
  class Sample
    @@global_volume = 0.5

    def self.volume; @@global_volume; end
    def self.volume=(value); @@global_volume = value; end

    alias_method :old_play, :play

    def play(volume = 1, speed = 1, looping = false)
      old_play(volume * @@global_volume, speed, looping)
    end
  end
end