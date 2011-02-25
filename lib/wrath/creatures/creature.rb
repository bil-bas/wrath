# encoding: utf-8

class Creature < WrathObject
  WALK_ANIMATION_DELAY = 200

  attr_reader :state

  FRAME_WALK1 = 0
  FRAME_WALK2 = 1
  FRAME_LIE = 2
  FRAME_SLEEP = 3

  def initialize(options = {})
    options = {
    }.merge! options

    super options

    @state = :standing

    @walking_animation = @frames[FRAME_WALK1..FRAME_WALK2]
    @walking_animation.delay = WALK_ANIMATION_DELAY
  end

  def update
    super

    self.image = case state
                   when :walking
                     z == 0 ? @walking_animation.next : @frames[FRAME_WALK1]
                   when :standing
                     @frames[FRAME_WALK1]
                   when :lying, :flying
                     @frames[FRAME_LIE]
                   when :sleeping, :dead
                     @frames[FRAME_SLEEP]
                   else
                    raise "unknown state: #{state}"
                 end
  end
end