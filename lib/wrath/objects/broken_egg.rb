module Wrath
class BrokenEgg < DynamicObject
  trait :timer

  ANIMATION_DELAY = 300
  EGGED_DURATION = 3 * 1000

  def can_be_dropped?; false; end

  public
  def initialize(options = {})
    options = {
      encumbrance: 0.9,
      z_offset: -5,
      animation: "broken_egg_6x5.png",
    }.merge! options

    super options
  end

  protected
  def on_being_picked_up(container)
    super(container)
    after(EGGED_DURATION) { destroy } unless parent.client?
  end

  def on_being_dropped(container)
    destroy
  end
end
end