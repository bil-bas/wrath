module Wrath

class Priest < Humanoid
  MAX_HEALTH = 100
  CHEER_SPRITE = 4

  def media_folder; 'players'; end

  def initialize(options = {})
    options = {
      speed: 2,
      encumbrance: 0.4,
      z_offset: -2,
      health: MAX_HEALTH,
    }.merge! options

    @animation_file = options[:animation]

    super(options)
  end

  def recreate_options
    {
        animation: @animation_file,
        local: remote?, # Invert locality of player created on client.
    }.merge! super
  end

  public
  # Called after game-over, when we want the player to be paused.
  def toggle_cheer
    self.image = (image == @frames[CHEER_SPRITE]) ? @frames[0] : @frames[CHEER_SPRITE]
  end
end
end