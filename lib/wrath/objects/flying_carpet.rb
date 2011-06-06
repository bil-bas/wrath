module Wrath
  class FlyingCarpet < DynamicObject
    trait :timer

    LEVITATE_HEIGHT = 15
    EXTRA_SPEED = 1
    FAVOUR_COST = 1 / 1000.0 # Minimal cost.

    def empowered?
      inside_container? and container.controlled_by_player? and
          container.player.favor > 0
    end

    def zorder; container ? container.zorder - 0.001 : super; end

    def mount?; true; end

    def initialize(options = {})
      options = {
        elasticity: 0.2,
        z_offset: -10,
        encumbrance: 0.5,
        elasticity: 0,
        animation: "carpet_12x3.png",
      }.merge! options

      super options
    end

    def on_being_dropped(actor)
      if actor.is_a? Creature
        actor.speed -= EXTRA_SPEED
        actor.flying_height -= LEVITATE_HEIGHT
      end

      self.image = @frames[0]
      stop_timer :flying_carpet
    end

    def on_being_picked_up(actor)
      if actor.is_a? Creature
        actor.speed += EXTRA_SPEED
        actor.flying_height += LEVITATE_HEIGHT

        self.image = @frames[1]

        every(500, name: :flying_carpet) do
          index = (image == @frames[1] and empowered?) ? 2 : 1
          self.image = @frames[index]
        end
      end
    end

    def update
      if inside_container? and not parent.client?
        if empowered?
          container.player.favor -= FAVOUR_COST * frame_time
        else
          container.drop
        end
      end

      super
    end
  end
end