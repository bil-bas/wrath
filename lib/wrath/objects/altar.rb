module Wrath

class Altar < StaticObject
  trait :timer

  BLOOD_DRIP_DELAY = 300
  BLOOD_DRIP_FRAME_RANGE = 1..4 # 4 frames of animation.
  GHOST_COLOR = Color.rgb(200, 200, 255)

  public
  def can_be_activated?(actor)
    actor.carrying? and
        not actor.mount? and
        not actor.contents.controlled_by_player? and
        not @sacrifice
  end

  public
  def initialize(options = {})
    options = {
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

  public
  def activated_by(actor)
    lamb = actor.contents
    case lamb
      when Creature
        @blood = 100
        @player = actor.player
        @sacrifice = lamb
        @blood_drip_animation.reset
        @facing = lamb.factor_x

      else
        # Instant gratification for inanimate objects.
        actor.player.favor += lamb.favor
    end

    if actor.local?
      parent.statistics.increment(:sacrifices, lamb.class.name[/[^:]+$/].to_sym)
    end

    @parent.send_message Message::PerformAction.new(actor, self) if parent.host?

    lamb.sacrificed(actor, self)
    lamb.destroy unless parent.client?
  end

  public
  def draw
    super

    if @sacrifice
      color = GHOST_COLOR.dup
      color.alpha = (@blood * 1.5).to_i
      @sacrifice.frames[0].draw_rot(x, y - height + (@blood - 100) / 5.0, zorder + y,
                                0, 0.5, 1, @facing, 1, color, :additive)
    end
  end

  public
  def update
    super

    if @blood > 0
      change = frame_time / 20.0
      @blood -= change
      @player.favor += parent.god.favor_for(@sacrifice) * change / 100.0

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
end