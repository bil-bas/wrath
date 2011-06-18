module Wrath
  class Bucket < DynamicObject
    SPRITE_EMPTY = 0
    SPRITE_WATER = 1
    SPRITE_LAVA = 2

    def initialize(options = {})
      options = {
        favor: -5,
        encumbrance: 0.2,
        elasticity: 0.2,
        z_offset: -1,
        animation: "bucket_7x9.png",
        factor: 0.7,
      }.merge! options

      super options

      self.image = @frames[SPRITE_EMPTY]
    end

#    def dropped
#      if parent.client?
#        super
#      else
#        actor.drop
#        actor.pick_up(BucketOfLava.create(parent: parent))
#        destroy
#      end
#    end
  end

  class BucketOfWater < Bucket
    def initialize(options = {})
      options = {
        encumbrance: 0.3,
      }.merge! options

      super options

      self.image = @frames[SPRITE_WATER]
    end
  end

  class BucketOfLava < Bucket
    def initialize(options = {})
      options = {
        encumbrance: 0.6,
      }.merge! options

      super options

      self.image = @frames[SPRITE_LAVA]
    end

    def dropped
      if parent.client?
        super
      else
        actor = container
        actor.pick_up(Fire.create(parent: parent))
        actor.drop
        actor.pick_up(Bucket.create(parent: parent))
        destroy
      end
    end
  end
end