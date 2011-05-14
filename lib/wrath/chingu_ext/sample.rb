module Gosu
  class Sample
    @@global_volume = GameState.settings[:audio, :effects_volume]

    def self.volume; @@global_volume; end
    def self.volume=(value); @@global_volume = value; end

    alias_method :old_play, :play

    def play(volume = 1, speed = 1, looping = false)
      old_play(volume * @@global_volume * Window.volume, speed, looping)
    end
  end
end