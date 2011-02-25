# encoding: utf-8

class Altar < StaticObject
  trait :timer

  CLEAR_DELAY = 25
  BLOOD_DRIP_DELAY = 300
  BLOOD_DRIP_FRAME_RANGE = 1..4 # 4 frames of animation.

  def ready?; @blood == 0; end

  def initialize(options = {})
    options = {
      x: 80,
      y: 60,
      animation: "altar_8x8.png",
    }.merge! options

    @blood = 0
    @player = nil
    @sacrifice = nil

    super(options)

    @blood_drip_animation = @frames[BLOOD_DRIP_FRAME_RANGE]
    @blood_drip_animation.delay = BLOOD_DRIP_DELAY
    @blood_drip_animation.loop = false
  end

  def sacrifice(player, sacrifice)
    case sacrifice
      when Mob
        @blood = 100
        @player = player
        @sacrifice = sacrifice
        @blood_drip_animation.reset
        after(CLEAR_DELAY) { clear_blood }
    end

    sacrifice.sacrificed(player, self)

  end

  def draw
    super

    unless ready?
      @sacrifice.image.draw(x - @sacrifice.image.width / 2, y - (height * 1.5) + (@blood - 100) / 10.0, zorder + y, 1, 1, Color.rgba(230, 230, 255, @blood + 25))
    end
  end

  def clear_blood
    if @blood > 0
      @blood -= 1
      @player.favor += @sacrifice.favor / 10 if @blood % 10 == 0
    end

    if ready?
      self.image = @frames[0]
      @sacrifice.ghost_disappeared
    else
      self.image = @blood_drip_animation.next
      after(CLEAR_DELAY) { clear_blood }
    end
  end
end