module Wrath

class Priest < Humanoid
  MAX_HEALTH = 100
  CHEER_SPRITE = 4

  NAMES = [:druidess, :monk, :priestess, :prophet, :seer, :shaman, :thaumaturge, :witch]

  def self.animation_file(name)
    "players/#{name}_8x8.png"
  end

  @@sprites = {} # Cache of sprite images (first sprite on sheet).

  def self.icon(name)
    @@sprites[name] = SpriteSheet.new(animation_file(name), 8, 8)[0]
  end

  def self.title(name); name.to_s.capitalize; end

  def initialize(options = {})
    options = {
      speed: 2,
      encumbrance: 0.4,
      z_offset: -2,
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