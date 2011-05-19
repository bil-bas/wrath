module Wrath
  class Potion < DynamicObject
    def can_be_activated?(actor); false; end

    def initialize(options = {})
      options = {
        favor: 2,
        encumbrance: 0,
        elasticity: 0.4,
        factor: 0.7,
        z_offset: 0,
        factor: 0.7,
      }.merge! options

      super options
    end

    def on_collision(other)
      case other
        when Creature
            affect(other)
            destroy
      end

      super(other)
    end
  end
end