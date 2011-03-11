# encoding: utf-8

class Creature < Carriable
  trait :timer

  WALK_ANIMATION_DELAY = 200
  STAND_UP_DELAY = 1000

  attr_reader :state

  FRAME_WALK1 = 0
  FRAME_WALK2 = 1
  FRAME_LIE = 2
  FRAME_THROWN = 2
  FRAME_CARRIED = 2
  FRAME_SLEEP = 3
  FRAME_DEAD = 3

  def initialize(options = {})
    options = {
    }.merge! options

    super options

    @state = :standing

    @walking_animation = @frames[FRAME_WALK1..FRAME_WALK2]
    @walking_animation.delay = WALK_ANIMATION_DELAY
  end

  def die!
    reset_forces
    self.image = @frames[FRAME_DEAD]
  end

  def update
    super

    self.image = case state
                   when :walking
                     z <= @tile.ground_level ? @walking_animation.next : @frames[FRAME_WALK1]
                   when :standing
                     @frames[FRAME_WALK1]
                   when :carried
                     @frames[FRAME_CARRIED]
                   when :lying
                     @frames[FRAME_LIE]
                   when :thrown
                     @frames[FRAME_THROWN]
                   when :sleeping
                     @frames[FRAME_SLEEP]
                   when :dead
                     @frames[FRAME_DEAD]
                   else
                     raise "unknown state: #{state}"
                 end
  end

  def pick_up(by)
    @state = :carried
    super(by)
  end

  def drop(*args)
    @state = :thrown
    super(*args)
  end

  def on_stopped
    # Stand up if we were thrown.
    after(STAND_UP_DELAY) { @state = :standing if @state == :thrown }

    super
  end
end