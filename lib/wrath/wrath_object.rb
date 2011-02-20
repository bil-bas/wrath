# encoding: utf-8

class WrathObject < GameObject
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

  def draw
    draw_relative(0, 0, y)
  end

  def spawn_position
    [rand(($window.width / $window.sprite_scale) - width) + width / 2,
     rand(($window.height / $window.sprite_scale) - height) + height / 2]
  end
end