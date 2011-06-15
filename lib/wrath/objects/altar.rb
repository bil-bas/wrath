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
        actor.contents.favor != 0
  end

  public
  def initialize(options = {})
    options = {
      animation: "altar_8x5.png",
      paused: false,
      interactive: true,
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
        @sacrifice = lamb
        @blood_drip_animation.reset
        @facing = lamb.factor_x
        sound = Sample["creatures/sacrifice.ogg"]
      else

        sound = lamb.favor > 0 ? Sample["creatures/sacrifice.ogg"] : Sample["objects/bad_sacrifice.ogg"]
    end

    actor.player.favor += lamb.favor
    sound.play_at_x(x, [[lamb.favor.abs, 20].min, 5].max / 20.0)

    if actor.local?
      parent.statistics.increment(:sacrifices, :type, lamb.class.name[/[^:]+$/].to_sym)

      type = case lamb
               when Humanoid      then :humanoids
               when Animal        then :animals
               when DynamicObject then :objects
             end
      parent.statistics.increment(:sacrifices, :totals, type)
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