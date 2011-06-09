module Wrath

class Priest < Humanoid
  MAX_HEALTH = 100
  CHEER_SPRITE = 4

  NAMES = [:acolyte, :cutie, :druidess, :monk, :priestess, :prophet, :seer, :shaman, :thaumaturge, :witch]
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
    "players/#{name}_8x8.png"
  end

  @@icons = {} # Icons for denoting locked and unlocked states.

  def self.icon(name)
    unless @@icons[name]
      unlocked_icon = SpriteSheet.new(animation_file(name), 8, 8)[0]

      locked_icon = unlocked_icon.silhouette
      locked_icon.clear color: LOCKED_COLOR, dest_ignore: :transparent
      @@icons[name] = { unlocked: unlocked_icon, locked: locked_icon }
    end

    manager = $window.achievement_manager
    if FREE_UNLOCKS.include?(name) or (manager and manager.unlocked?(:priest, name))
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