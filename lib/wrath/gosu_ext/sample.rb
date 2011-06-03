module Gosu
  class Sample
    def play_at_x(x, *args)
      play_pan(-1 + (($window.retro_width * 2.0) / x), *args)
    end
  end
end