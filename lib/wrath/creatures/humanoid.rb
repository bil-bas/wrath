module Wrath
  # Humanoids are any sort of intelligent people. They move by "gliding" rather than bouncing.
  # Only humanoids can be controlled by a player (but only because they are the only ones that can guarantee a decent
  # portrait image)
  class Humanoid < Creature
    PORTRAIT_WIDTH = 7
    PORTRAIT_CROP = [1, 0, 5, 4]
    PORTRAIT_PADDING = 1

    def controlled_by_player?; not @player.nil?; end

    def initialize(options = {})
      options = {
          encumbrance: 0.4,
          health: 30,
          speed: 1,
          z_offset: -2,
          elasticity: 0.3,
          move_type: :walk,
          walk_duration: 2000,
      }.merge! options

      @player = nil

      super(options)
    end

    public
    def player=(player)
      @player = player

      if controlled_by_player?
        halt
      else
        schedule_move
      end
    end

    public
    # Small portrait used on the screen to represent a player.
    def portrait
      unless @portrait
        @portrait = TexPlay.create_image($window, PORTRAIT_WIDTH, PORTRAIT_WIDTH)
        @frames[0].refresh_cache
        @portrait.splice @frames[0], PORTRAIT_PADDING, PORTRAIT_PADDING, crop: PORTRAIT_CROP, alpha_blend: true
      end

      @portrait
    end
  end
end