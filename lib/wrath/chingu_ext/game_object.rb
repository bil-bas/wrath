# encoding: utf-8

class GameObject
  def distance_to(other)
    Math.sqrt((x - other.x) ** 2 + (y - other.y) ** 2 + (y - other.y) ** 2)
  end
end