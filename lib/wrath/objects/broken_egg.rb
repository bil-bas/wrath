module Wrath
class BrokenEgg < Carriable
  trait :timer

  ANIMATION_DELAY = 300
  EGGED_DURATION = 3 * 1000

  def can_drop?; @can_drop; end

  def initialize(options = {})
    options = {
      encumbrance: 0.9,
      z_offset: -5,
      animation: "broken_egg_6x5.png",
    }.merge! options

    @can_drop = false

    super options
  end

  def picked_up(*args)
    super

    after(EGGED_DURATION) do
      @can_drop = true
      carrier.drop if carrier
      destroy
    end
  end
end
end