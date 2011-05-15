module Wrath
  class TiedRope < DynamicObject
    trait :timer

    TIED_DURATION = 4 * 1000

    def can_be_dropped?(container); false; end

    public
    def initialize(options = {})
      options = {
        encumbrance: 0.9,
        z_offset: -8,
        animation: "rope_10x6.png",
      }.merge! options

      super options

      self.image = @frames[1]
    end

    protected
    def on_being_picked_up(container)
      super(container)
      after(TIED_DURATION) { destroy } unless parent.client?
    end

    def on_being_dropped(container)
      destroy
    end
  end
end