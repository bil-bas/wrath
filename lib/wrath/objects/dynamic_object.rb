module Wrath
  # An object that can move around and be picked up and put into things.
  class DynamicObject < BaseObject
    attr_reader :container, :thrown_by, :z_offset
    attr_reader :encumbrance
    attr_writer :encumbrance

    def can_be_dropped?(container); true; end
    def can_be_picked_up?(container)
      not @thrown_by.include? container # So you can't pick something up the moment you throw it.
    end
    def inside_container?; not @container.nil?; end
    def affected_by_gravity?; @container.nil?; end
    def can_be_activated?(actor); can_be_picked_up?(actor) and actor.empty_handed?; end

    def on_being_picked_up(by); end
    def on_being_dropped(by); end
    def thrown?; not @thrown_by.empty?; end

    public
    def initialize(options = {})
      options = {
          encumbrance: 0.2,
          z_offset: 0,
      }.merge! options

      @encumbrance = options[:encumbrance]
      @z_offset = options[:z_offset]

      @thrown_by = [] # These will be immune from colliding with the object.

      super options

      parent.objects << self if networked?
    end

    public
    def can_knock_down_creature?(creature)
      encumbrance >= creature.encumbrance * 0.5 and
      thrown? and not thrown_by.include? creature
    end

    public
    def activated_by(actor)
      actor.pick_up(self)
    end

    protected
    def on_stopped
      super
      @thrown_by.clear
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
    def on_collision(other)
      case other
        when Wall
          # Everything, except carried objects, hit walls.
          (not (can_pick_up? and inside_container?))

        else
          false
      end
    end

    public
    def halt
      set_body_velocity(0, 0)
    end

    public
    def destroy
      @container.drop if inside_container?
      parent.objects.delete self if parent
      super
    end
  end
end