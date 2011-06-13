module Wrath
  class Preload < GameState
    def initialize
      super

      @preload_priests = Priest::NAMES.dup
      @started_preload_at = Time.now
    end

    def update
      if @preload_priests.empty?
        log.info { "Preloaded priest icons in #{Time.now - @started_preload_at} seconds" }
        @started_preload_at = Time.now

        $window.preload_init

        switch_game_state Menu
      else
        Priest.animation(@preload_priests.pop)
      end
    end
  end
end