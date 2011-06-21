module Wrath
  # A campfire that burns and can be picked up and thrown.
  class CampFire < DynamicObject
    def sacrifice_particle; burning? ? Spark : super; end

    def initialize(options = {})
      options = {
          favor: 2,
          encumbrance: 0.2,
          elasticity: 0.2,
          z_offset: -2,
          animation: "camp_fire_8x4.png",
          collision_height: 6, # Encourage the flames to be nice and big :)
          burning: true,
          flammable: true,
      }.merge! options

      super options

      apply_status :burning if options[:burning]
    end

    def apply_status(type, options = {})
      # Ensure that when we burn, we burn forever!
      if type == :burning
        options = options.dup
        options.delete(:duration)
      end

      super(type, options)
    end

    def on_collision(other)
      if other.flammable? and burning?
        other.apply_status(:burning, duration: Status::Burning::DEFAULT_PRIMARY_BURN_DURATION)
      end

      super(other)
    end
  end
end