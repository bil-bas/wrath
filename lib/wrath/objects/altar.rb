# encoding: utf-8

class Altar < StaticObject
  trait :timer

  BLOOD_DRIP_DELAY = 300
  BLOOD_DRIP_FRAME_RANGE = 1..4 # 4 frames of animation.
  GHOST_COLOR = Color.rgb(200, 200, 255)

  def can_be_activated?(actor); actor.carrying and not actor.mount? and not actor.carrying.player and not @sacrifice; end

  def initialize(options = {})
    options = {
      x: 80,
      y: 60,
      animation: "altar_8x5.png",
    }.merge! options

    @blood = 0
    @actor = nil
    @sacrifice = nil

    super(options)

    @blood_drip_animation = @frames[BLOOD_DRIP_FRAME_RANGE]
    @blood_drip_animation.delay = BLOOD_DRIP_DELAY
    @blood_drip_animation.loop = false
  end

  def activate(actor)
    lamb = actor.carrying
    actor.drop
    sacrifice(actor, lamb)
  end

  def sacrifice(actor, sacrifice)
    case sacrifice
      when Mob
        @blood = 100
        @player = actor.player
        @sacrifice = sacrifice
        @blood_drip_animation.reset
        @facing = sacrifice.factor_x
    end

    sacrifice.sacrificed(actor, self)
  end

  def draw
    super

    if @sacrifice
      color = GHOST_COLOR.dup
      color.alpha = (@blood * 1.5).to_i
      @sacrifice.frames[0].draw_rot(x, y - height + (@blood - 100) / 10.0, zorder + y,
                                0, 0.5, 1, @facing, 1, color, :additive)
    end
  end

  def update
    super

    if @blood > 0
      change = frame_time / 20.0
      @blood -= change
      @player.favor += @sacrifice.favor * change / 100.0

      if @blood <= 0
        self.image = @frames[0]
        @sacrifice.ghost_disappeared
        @sacrifice = nil
      else
        self.image = @blood_drip_animation.next
      end
    end
  end
end