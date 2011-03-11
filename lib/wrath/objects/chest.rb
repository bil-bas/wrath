class Chest < Carriable
  trait :timer

  def open?; not @contains; end
  def closed?; @contains; end
  def can_pick_up?; not @contains; end

  CLOSED_SPRITE_FRAME = 0
  OPEN_SPRITE_FRAME = 1

  EXPLOSION_H_SPEED = 0.3..0.5
  EXPLOSION_Z_VELOCITY = 0.5..0.9
  EXPLOSION_NUMBER = 6..8

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
      elasticity: 0.6,
      z_offset: -2,
      animation: "chest_8x8.png",
      open: false,
    }.merge! options

    super options

    @sacrificial_explosion = Explosion.new(type: Splinter, number: EXPLOSION_NUMBER, h_speed: EXPLOSION_H_SPEED,
                                           z_velocity: EXPLOSION_Z_VELOCITY)

    # Pick one of the contents objects, creating if it is a class rather than an object.
    if options[:contains]
      possible_objects = Array(options[:contains])
      object = possible_objects[rand(possible_objects.size)]
      object = object.create(x: -1000 * id) if object.is_a? Class
      close(object, quiet: true)
    else
      open(quiet: true)
    end
  end

  def can_be_activated?(actor)
    (closed? and actor.empty_handed?) or open?
  end

  def activate(actor)
    if closed?
      open
    else
      item = actor.carrying
      if item
        actor.carrying = nil
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

  def sacrificed(player, altar)
    Sample["rock_sacrifice.wav"].play
    super
  end

  def close(object, options = {})
    Sample["chest_close.wav"].play unless options[:quiet]

    object.put_into(self)

    if object.is_a? Creature
      every(2000 + rand(100), name: :bounce) { self.z_velocity = 0.8 }
    end

    self.image = @frames[CLOSED_SPRITE_FRAME]
    @contains = object
    @contains.x = -1000 * id
    @contains.pause!
  end
end