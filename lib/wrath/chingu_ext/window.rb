module Gosu
  class Window
    @@global_volume = 0.5

    def self.volume; @@global_volume; end
    def self.volume=(value); @@global_volume = value; end


    @@restart = false
    def self.restart=(value); @@restart = value; end
    def self.restart?; @@restart; end
  end
end