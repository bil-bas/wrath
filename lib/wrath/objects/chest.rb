class Chest < StaticObject
  trait :timer

  include Carriable

  def open?; not @contains; end
  def closed?; @contains; end
  def carriable?; not @contains; end

  CLOSED_SPRITE_FRAME = 0
  OPEN_SPRITE_FRAME = 1

  def initialize(options = {})
    options = {
      encumbrance: 0.6,
      elasticity: 0.6,
      animation: "chest_8x8.png",
      open: false,
    }.merge! options

    super options

    # Pick one of the contents objects, creating if it is a class rather than an object.
    if options[:contains]
      possible_objects = Array(options[:contains])
      object = possible_objects[rand(possible_objects.size)]
      object = object.create if object.is_a? Class
      close(object)
    else
      open
    end
  end

  def open
    self.image = @frames[OPEN_SPRITE_FRAME]

    if @contains
      $window.current_game_state.objects.push @contains
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

  def close(object)
    object.put_into(self)

    if object.is_a? Creature
      every(2000 + rand(100), name: :bounce) { self.z_velocity = 0.8 }
    end

    self.image = @frames[CLOSED_SPRITE_FRAME]
    @contains = object
    @contains.x = -1000
    @contains.pause!
  end
end