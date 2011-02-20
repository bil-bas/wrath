# encoding: utf-8

class WrathObject < GameObject
  trait :retrofy

  def zorder; @y; end # This is specifically @y, not #y, which might be higher up.

  def initialize(options)
    options = {
      rotation_center: :bottom_center,
      spawn: false,
    }.merge! options

    super(options)

    spawn if options[:spawn]
  end


  def spawn
    self.x, self.y = spawn_position
  end

  def spawn_position
    [rand(($window.width / $window.factor) - width) + width / 2,
     rand(($window.height / $window.factor) - height) + height / 2]
  end
end