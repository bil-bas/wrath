module Wrath
  class FlyingCarpet < DynamicObject
    trait :timer

    LEVITATE_HEIGHT = 15
    LEVITATE_SPEED = 0.05
    FAVOUR_COST = 1 / 1000.0 # Minimal cost.


    # Speeds the user up while flying, but not on the ground.
    def encumbrance
      (empowered? and container.z > container.ground_level) ? -0.25 : 0.5
    end

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
        encumbrance: -0.25,
        animation: "carpet_12x3.png",
      }.merge! options

      super options
    end

    def on_being_dropped(actor)
      self.image = @frames[0]
      stop_timer :flying_carpet
    end

    def on_being_picked_up(actor)
      self.image = @frames[1]
      every(500, name: :flying_carpet) do
        index = (image == @frames[1] and empowered?) ? 2 : 1
        self.image = @frames[index]
      end
    end

    def update
      if inside_container? and not parent.client?
        if empowered?
          container.z_velocity = [LEVITATE_HEIGHT - container.z, 0].max * LEVITATE_SPEED
          container.player.favor -= FAVOUR_COST * frame_time
        else
          container.drop
        end
      end

      super
    end
  end
end