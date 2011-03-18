module Wrath
class Chest < Carriable
  trait :timer

  def open?; not @contains; end
  def closed?; @contains; end
  def can_pick_up?; not @contains; end

  PLAYER_TRAPPED_DURATION = 2000

  CLOSED_SPRITE_FRAME = 0
  OPEN_SPRITE_FRAME = 1

  EXPLOSION_H_SPEED = 0.5..1.0
  EXPLOSION_Z_VELOCITY = 0.5..0.9
  EXPLOSION_NUMBER = 15..20

  # Minimum "size" of a creature so it bounces the chest it is in.
  MIN_BOUNCE_ENCUMBRANCE = 0.4

  def initialize(options = {})
    options = {
      favor: -10,
      encumbrance: 0.5,
      elasticity: 0.6,
      z_offset: -2,
      animation: "chest_8x8.png",
    }.merge! options

    # Pick one of the contents objects, creating if it is a class rather than an object.
    @contains = if options[:contains]
                  possible_objects = Array(options[:contains])
                  object = possible_objects[rand(possible_objects.size)]
                  object = object.create(x: -100 * rand(100), y: -100 * rand(100)) if object.is_a? Class
                  object

                elsif options[:contains_id]
                  parent = options[:parent] || $window.current_game_state
                  parent.object_by_id(options[:contains_id])

                else
                  nil
                end

    super options

    if @contains
      close(@contains, quiet: true)
    else
      open(quiet: true)
    end

    @sacrificial_explosion = Emitter.new(Splinter, parent, number: EXPLOSION_NUMBER, h_speed: EXPLOSION_H_SPEED,
                                           z_velocity: EXPLOSION_Z_VELOCITY)
  end

  def recreate_options
    super.merge! contains_id: @contains.id
  end

  def can_be_activated?(actor)
    (closed? and actor.empty_handed?) or open?
  end

  def activate(actor)
    @parent.send_message Message::PerformAction.new(actor, self) if parent.host?

    if closed?
      open
    else
      item = actor.carrying
      if item
        actor.drop
        close(item)
      else
        actor.pick_up(self)
      end
    end
  end

  def open(options = {})
    Sample["chest_close.wav"].play unless options[:quiet]

    self.image = @frames[OPEN_SPRITE_FRAME]

    if @contains
      parent.objects.push @contains
      @contains.x = x
      @contains.y = y
      @contains.z = z + 6
      @contains.z_velocity =  1
      @contains.y_velocity = 0.1

      @contains.unpause!

      stop_timer :bounce
    end

    @contains = nil
  end

  def sacrificed(actor, altar)
    Sample["rock_sacrifice.wav"].play
    super
  end

  def close(object, options = {})
    Sample["chest_close.wav"].play unless options[:quiet]

    object.put_into(self)

    self.image = @frames[CLOSED_SPRITE_FRAME]
    @contains = object
    @contains.velocity = [0, 0, 0]
    @contains.x = -1000 * id
    @contains.pause!

    unless parent.client?
      if object.is_a? Creature and object.encumbrance >= MIN_BOUNCE_ENCUMBRANCE
        every(1500 + rand(500), name: :bounce) { self.z_velocity = 0.8 }
      end

      if @contains.controlled_by_player?
        after(PLAYER_TRAPPED_DURATION) do
          if @contains == object
            open
            parent.send_message(Message::PerformAction.new(object, self))
          end
        end
      end
    end
  end
end
end