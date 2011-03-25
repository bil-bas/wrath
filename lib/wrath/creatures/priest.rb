module Wrath

class Priest < Humanoid
  MAX_HEALTH = 100

  def media_folder; 'players'; end

  def initialize(options = {})
    options = {
      speed: 2,
      encumbrance: 0.4,
      elasticity: 0.1,
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
end
end