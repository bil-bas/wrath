# encoding: utf-8

class Priest < Creature
  MAX_HEALTH = 100

  def can_pick_up?; false; end
  def can_be_activated?(actor); false; end

  def initialize(options = {})
    options = {
      speed: 2,
      favor: 10,
      health: MAX_HEALTH,
    }.merge! options

    @animation_file = options[:animation]

    super(options)
  end

  def recreate_options
    {
        animation: @animation_file,
        local: remote?, # Invert locality of player created on client.
        number: number
    }.merge! super
  end
end