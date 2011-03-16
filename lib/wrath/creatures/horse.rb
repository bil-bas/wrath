module Wrath

class Horse < Mob
  def mount?; true; end

  def initialize(options = {})
    options = {
      favor: 20,
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.6,
      jump_delay: 600,
      encumbrance: 0.4,
      z_offset: -3,
      speed: 4,
      animation: "horse_12x11.png",
    }.merge! options

    super(options)
  end

  # Mount the horsie or push off whoever is riding on it.
  def activate(actor)
    if carrying?
      drop
    else
      pick_up(actor)
    end
  end

  # Dismount the horsie.
  def drop
    if controlled_by_player?
      self.local = (not parent.client?) # Revert to owned by host.
      schedule_jump
    end

    self.z_velocity = 0.8

    super
  end

  def pick_up(object)
    if object.controlled_by_player?
      self.local = object.local? # If you pick up a player, change to its locality.
      stop_timer(:jump)
    end

    super
  end
end

end