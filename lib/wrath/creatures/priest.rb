module Wrath

class Priest < Humanoid
  MAX_HEALTH = 100
  CHEER_SPRITE = 4

  NAMES = [:acolyte, :chaplain, :cutie, :druidess, :monk, :nun, :priestess, :prophet, :scientist, :seer, :shaman, :thaumaturge, :witch]
  FREE_UNLOCKS = [:monk, :witch] # Others must be manually unlocked.
  LOCKED_COLOR = Color.rgba(150, 150, 150, 200)

  def breathes?(substance)
    case substance
      when :air
        @name != :shaman
      when :water
        [:cutie, :acolyte].include? @name
      when :space
        [:cutie, :shaman].include? @name
      else
        "unknown substance #{substance}"
    end
  end

  def self.animation_file(name)
    "players/#{name}_8x10.png"
  end

  @@icons = {} # Icons for denoting locked and unlocked states.
  @@animations = {}

  def self.animation(name)
    unless @@animations.has_key? name
      @@animations[name] = Animation.new(file: animation_file(name))
    end

    @@animations[name]
  end

  def self.unlocked?(name)
    manager = $window.achievement_manager
    FREE_UNLOCKS.include?(name) or (manager and manager.unlocked?(:priest, name))
  end

  def self.icon(name)
    unless @@icons[name]
      unlocked_icon = animation(name)[0]

      locked_icon = unlocked_icon.silhouette
      locked_icon.clear color: LOCKED_COLOR, dest_ignore: :transparent
      @@icons[name] = { unlocked: unlocked_icon, locked: locked_icon }
    end

    if unlocked?(name)
      @@icons[name][:unlocked]
    else
      @@icons[name][:locked]
    end
  end

  def self.title(name); t.priest[name].name; end

  def initialize(options = {})
    options = {
      speed: 2,
      health: MAX_HEALTH,
      collision_width: 8,
      collision_height: 8,
    }.merge! options

    @name = options[:name]
    options[:animation] = self.class.animation(@name).dup

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