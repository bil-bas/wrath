module Wrath
  # Huge, black witch's cauldron. Can be worn over most the body or can brew potions from specific ingredients.
  class Cauldron < DynamicObject
    trait :timer

    IMAGE_UPRIGHT = 0
    IMAGE_INVERTED = 1
    IMAGE_BREWING = 2
    SMOKE_COLOR = Color.rgba(0, 200, 0, 150)

    def initialize(options = {})
      options = {
        animation: "cauldron_10x8.png",
        encumbrance: 0.6,
        z_offset: -6,
      }.merge! options

      @brewing = false

      super options
    end

    def can_be_activated?(actor)
      (actor.empty_handed? or actor.contents.is_a? Mushroom) and not @brewing
    end

    def on_being_picked_up(container)
      self.image = @frames[IMAGE_INVERTED]
    end

    def on_being_dropped(container)
      self.image = @frames[IMAGE_UPRIGHT]
    end

    def activated_by(actor)
      if actor.empty_handed?
        actor.pick_up(self)
      else
        # Brew a strength potion from a mushroom.
        shroom = actor.contents
        actor.drop
        shroom.destroy

        brew StrengthPotion
      end
    end

    def brew(result)
      @brewing = true

      self.image = @frames[IMAGE_BREWING]
      after(3000) { complete_brew(result) }
    end

    def update
      super

      if @brewing and rand(100) < 20
         Smoke.create(parent: parent, x: x - 3 + rand(4) + rand(4), y: y - z - height, zorder: zorder - 0.001, color: SMOKE_COLOR)
      end
    end

    def complete_brew(result)
      @brewing = false
      self.image = @frames[IMAGE_UPRIGHT]
      result.create(parent: parent, x: x, y: y, z: z + height, velocity: [0, 0.1, 0.5]) unless parent.client?
    end
  end
end