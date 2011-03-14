class GameObject
  def distance_to(other)
    Math.sqrt((x - other.x) ** 2 + (y - other.y) ** 2 + (z - other.z) ** 2)
  end
end