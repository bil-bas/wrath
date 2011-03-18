module Wrath
  class OgreSkull < DynamicObject
    FRAME_GROUND = 0
    FRAME_WORN = 1

    def initialize(options = {})
      options = {
        favor: -1,
        encumbrance: 0.3,
        elasticity: 0.4,
        z_offset: -5,
        animation: "ogre_skull_8x8.png",
      }.merge! options

      super  options
    end

    def picked_up(actor)
      super(actor)
      self.image = @frames[FRAME_WORN]
    end

    def dropped(actor, *velocity)
      super(actor, *velocity)
      self.image = @frames[FRAME_GROUND]
    end
  end
end