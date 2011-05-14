module Gosu
  class Sample
    @@global_volume = GameState.settings[:audio, :effects_volume]

    def self.volume; @@global_volume; end
    def self.volume=(value); @@global_volume = value; end

    alias_method :old_play, :play

    def play(volume = 1, speed = 1, looping = false)
      effective_volume = volume * @@global_volume * Window.volume
      old_play(effective_volume, speed, looping) if effective_volume > 0.0
    end
  end
end