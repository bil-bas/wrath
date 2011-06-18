require_relative "base_object" # Needed to prevent events being created out of sync via require_all.

module Wrath
  # An object that can move around and be picked up and put into things.
  class DynamicObject < BaseObject
    include HasStatus

    event :on_having_wounded # Not client-side.

    MIN_ENCUMBRANCE_TO_KNOCK_DOWN = 0.2 # Enough weight to knock creatures over when hit by them.

    attr_reader :container, :thrown_by, :z_offset, :damage_per_second, :damage_per_hit
    attr_reader :encumbrance
    attr_writer :encumbrance

    def hurts?(other); @damage_per_hit > 0 or @damage_per_second > 0; end
    def can_be_dropped?; true; end
    def can_be_picked_up?(container)
      not @thrown_by.include? container # So you can't pick something up the moment you throw it.
    end
    def inside_container?; not @container.nil?; end
    def affected_by_gravity?; @container.nil?; end
    def can_be_activated?(actor); can_be_picked_up?(actor) and actor.empty_handed?; end

    def on_being_picked_up(by); end
    def on_being_dropped(by); end
    def thrown?; not @thrown_by.empty?; end
    def flammable?; @flammable; end

    public
    def initialize(options = {})
      options = {
          damage_per_hit: 0,
          damage_per_second: 0,
          encumbrance: 0.2,
          z_offset: 0,
          flammable: false,
      }.merge! options

      @encumbrance = options[:encumbrance]
      @z_offset = options[:z_offset]

      @damage_per_hit = options[:damage_per_hit]
      @damage_per_second = options[:damage_per_second]

      @thrown_by = [] # These will be immune from colliding with the object.

      super options

      parent.objects << self if networked?
    end

    public
    # Can knock down something by just hitting it, rather than doing actual damage.
    def can_knock_down_creature?(creature)
      encumbrance >= MIN_ENCUMBRANCE_TO_KNOCK_DOWN and
      thrown? and not thrown_by.include? creature
    end

    public
    def activated_by(actor)
      actor.pick_up(self)
    end

    public
    def dropped
      dropper = @container
      @thrown_by = [dropper]
      @container = nil
      parent.objects << self

      on_being_dropped(dropper)
      nil
    end

    public
    def picked_up_by(container)
      @container = container
      parent.objects.delete self

      on_being_picked_up(container)
      nil
    end

    public
    def can_hit?(other)
      damage_per_hit > 0 and @container != other and other.container != self and
          not thrown_by.include?(other) and not other.thrown_by.include?(self)
    end

    public
    def on_collision(other)
      case other
        when Wall
          # Everything, except carried objects, hit walls.
          not inside_container?

        when DynamicObject
          apply_status(:burning, duration: Status::Burning::DEFAULT_BURN_DURATION) if flammable? and other.burning?

          false

        else
          false
      end
    end

    public
    # You knocked someone (else) down, either by being thrown at them or by hitting them.
    def knocked_someone_down(knockee)
      thrown_by << knockee if thrown?

      nil
    end

    public
    def halt
      @thrown_by.clear
      set_body_velocity(0, 0)
      super
    end

    public
    def destroy
      @container.drop if inside_container? and exists?
      parent.objects.delete self if exists?

      super
    end
  end
end