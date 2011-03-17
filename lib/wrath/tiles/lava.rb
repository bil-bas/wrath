module Wrath
class Lava < Water
  ANIMATION_POSITIONS = [[0, 2], [1, 2]]
  IMAGE_POSITION_FILLED = [2, 3]

  DAMAGE = 20 / 1000.0 # 20/second
  FILLED_DAMAGE = 2 / 1000.0 # Still take some damage when standing on the rock.

  def touched_by(object)
    case object
      when Rock
        unless filled?
          object.destroy
          @filled = true
          @ground_level = FULL_LEVEL
          @speed = 1
        end

      when Creature
        damage = filled? ? FILLED_DAMAGE : DAMAGE
        object.health -= damage * parent.frame_time unless parent.client?

      else
        object.destroy
    end
  end
end
end