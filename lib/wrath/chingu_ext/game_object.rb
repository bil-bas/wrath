# encoding: utf-8

class GameObject
  def distance_to(other)
    distance(x, y, other.x, other.y)
  end
end