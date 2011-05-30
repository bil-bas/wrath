module Wrath

class Priest < Humanoid
  MAX_HEALTH = 100
  CHEER_SPRITE = 4

  NAMES = [:druidess, :monk, :priestess, :prophet, :seer, :shaman, :thaumaturge, :witch]
  FREE_UNLOCKS = [:monk, :witch] # Others must be manually unlocked.
  LOCKED_COLOR = Color.rgba(150, 150, 150, 200)

  def self.animation_file(name)
    "players/#{name}_8x8.png"
  end

  @@sprites = {} # Cache of sprite images (first sprite on sheet).

  def self.icon(name)
    icon = SpriteSheet.new(animation_file(name), 8, 8)[0]
    manager = $window.achievement_manager
    unless FREE_UNLOCKS.include?(name) or (manager and manager.unlocked?(:priest, name))
      icon = icon.silhouette
      icon.clear color: LOCKED_COLOR, dest_ignore: :transparent
    end
    icon
  end

  def self.title(name); name.to_s.capitalize; end

  def initialize(options = {})
    options = {
      speed: 2,
      health: MAX_HEALTH,
    }.merge! options

    @name = options[:name]
    options[:animation] = Animation.new(file: self.class.animation_file(@name))

    super(options)
  end

  def recreate_options
    {
        name: @name,
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