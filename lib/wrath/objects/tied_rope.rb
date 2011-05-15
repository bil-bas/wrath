module Wrath
  class TiedRope < DynamicObject
    trait :timer

    TIED_DURATION = 4 * 1000

    def can_be_dropped?(container); @can_be_dropped; end

    public
    def initialize(options = {})
      options = {
        encumbrance: 0.9,
        z_offset: -8,
        animation: "rope_10x6.png",
      }.merge! options

      @can_be_dropped = false

      super options

      self.image = @frames[1]
    end

    protected
    def on_being_picked_up(container)
      super(container)
      after(TIED_DURATION) { destroy } unless parent.client?
    end

    public
    def destroy
      @can_be_dropped = true
      super
    end
  end
end