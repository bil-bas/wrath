# encoding: utf-8

class Altar < StaticObject
  trait :timer

  CLEAR_DELAY = 25
  BLOOD_DRIP_DELAY = 300
  BLOOD_DRIP_FRAME_RANGE = 1..4 # 4 frames of animation.
  GHOST_COLOR = Color.rgb(200, 200, 255)

  def can_be_activated?(actor); actor.carrying and not @sacrifice; end

  def initialize(options = {})
    options = {
      x: 80,
      y: 60,
      animation: "altar_8x5.png",
    }.merge! options

    @blood = 0
    @player = nil
    @sacrifice = nil

    super(options)

    @blood_drip_animation = @frames[BLOOD_DRIP_FRAME_RANGE]
    @blood_drip_animation.delay = BLOOD_DRIP_DELAY
    @blood_drip_animation.loop = false
  end

  def activate(actor)
    lamb = actor.carrying
    actor.carrying = nil
    sacrifice(actor, lamb)
  end

  def sacrifice(player, sacrifice)
    case sacrifice
      when Mob
        @blood = 100
        @player = player
        @sacrifice = sacrifice
        @blood_drip_animation.reset
        @facing = sacrifice.factor_x
        after(CLEAR_DELAY) { clear_blood }
    end

    sacrifice.sacrificed(player, self)

  end

  def draw
    super

    if @sacrifice
      color = GHOST_COLOR.dup
      color.alpha = (@blood * 1.5).to_i
      @sacrifice.image.draw_rot(x, y - height + (@blood - 100) / 10.0, zorder + y,
                                0, 0.5, 1, @facing, 1, color, :additive)
    end
  end

  def clear_blood
    if @blood > 0
      @blood -= 1
      @player.favor += @sacrifice.favor / 10 if @blood % 10 == 0
    end

    if @blood <= 0
      self.image = @frames[0]
      @sacrifice.ghost_disappeared
      @sacrifice = nil
    else
      self.image = @blood_drip_animation.next
      after(CLEAR_DELAY) { clear_blood }
    end
  end
end