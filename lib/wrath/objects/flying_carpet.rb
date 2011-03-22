module Wrath
  class FlyingCarpet < Crown

    def zorder; container ? container.zorder - 0.001 : super; end

    def mount?; true; end

    def initialize(options = {})
      options = {
        elasticity: 0.2,
        z_offset: -10,
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
      container.drop if inside_container? and not empowered?
      super
    end

    # Speeds the user up while flying, but does not allow any movement on the ground.
    def encumbrance
      (empowered? and container.z > container.ground_level) ? -0.25 : 1
    end
  end
end