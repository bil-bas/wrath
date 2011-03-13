class Egg < Carriable
  trait :timer

  GESTATION_DELAY = 3 * 1000

  def initialize(options = {})
    options = {
      favor: 1,
      encumbrance: 0,
      elasticity: 0.4,
      factor: 0.7,
      z_offset: 0,
      animation: "egg_4x5.png",
    }.merge! options

    super options
  end

  def on_stopped
    super
    after(GESTATION_DELAY, name: :gestation) { hatch }
  end

  def picked_up(*args)
    super(*args)
    stop_timer(:gestation)
  end

  def hatch
    parent.objects << Chicken.create(position: position, parent: parent)
    destroy
  end

  def on_collision(other)
    case other
      when Priest, Virgin, Knight, Paladin, Bard # TODO: Humanoid?
        if not thrown_by.include? other and (not carried?) and z > ground_level
          other.drop
          other.pick_up(BrokenEgg.create(parent: parent))
          destroy
        end
    end

    super(other)
  end
end