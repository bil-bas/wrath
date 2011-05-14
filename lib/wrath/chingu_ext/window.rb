module Gosu
  class Window
    @@global_volume = GameState.settings[:audio, :master_volume]

    def self.volume; @@global_volume; end
    def self.volume=(value); @@global_volume = value; end
  end
end