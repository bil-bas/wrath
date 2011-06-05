module Wrath
# The basic "thing that contains stuff that you can put stuff in or take it out"
class Chest < Container
  trait :timer

  PLAYER_TRAPPED_DURATION = 2000

  CLOSED_SPRITE_FRAME = 0
  OPEN_SPRITE_FRAME = 1

  EXPLOSION_H_SPEED = 0.5..1.0
  EXPLOSION_Z_VELOCITY = 0.5..0.9
  EXPLOSION_NUMBER = 15..20

  # Minimum "size" of a creature so it bounces the chest it is in.
  MIN_BOUNCE_ENCUMBRANCE = 0.4

  CHEST_OPEN_SOUND = "objects/chest_close.ogg"
  CHEST_CLOSED_SOUND = "objects/chest_close.ogg"

  alias_method :open?, :empty?
  alias_method :closed?, :full?

  public
  def initialize(options = {})
    options = {
      favor: -10,
      encumbrance: 0.5,
      elasticity: 0.3,
      z_offset: -2,
      animation: "chest_8x8.png",
      hide_contents: true,
      drop_velocity: [0, 0.15, 0.5],
    }.merge! options

    super options

    # Ensure our initial state is correct.
    open? ? open : close
  end

  public
  def can_be_activated?(actor)
    if actor.empty_handed?
      true
    else      
      open? and actor.contents.can_be_dropped?
    end
  end

  public
  def activated_by(actor)
    @parent.send_message Message::PerformAction.new(actor, self) if parent.host?

    if closed?
      # Open the chest and spit out its contents.
      drop
    elsif actor.empty_handed?
        # Pick up the empty chest.
        actor.pick_up(self)
    else
      # Put object into chest.
      item = actor.contents
      actor.drop
      pick_up(item)
    end
  end

  public
  def on_having_dropped(object)
    super(object)
    open
    Sample[CHEST_CLOSED_SOUND].play_at_x(x)
    stop_timer :bounce
    object.position = [x, y, z + 6] # So the object pops out the top of the chest.
  end

  def on_having_picked_up(object)
    super(object)
    close

    Sample[CHEST_CLOSED_SOUND].play_at_x(x) if parent.started? # Don't make noises before game starts!

    unless parent.client?
      if object.is_a? Creature and object.encumbrance >= MIN_BOUNCE_ENCUMBRANCE
        every(1500 + rand(500), name: :bounce) { self.z_velocity = 0.8 }
      end

      if contents.controlled_by_player?
        after(PLAYER_TRAPPED_DURATION) { drop if contents == object }
      end
    end
  end

  protected
  def open
    self.image = @frames[OPEN_SPRITE_FRAME]
  end

  protected
  def close
    self.image = @frames[CLOSED_SPRITE_FRAME]
  end
end
end