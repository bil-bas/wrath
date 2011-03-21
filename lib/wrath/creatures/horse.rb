module Wrath

class Horse < Mob
  def mount?; true; end

  public
  def initialize(options = {})
    options = {
      favor: 20,
      health: 30,
      vertical_jump: 0.2,
      horizontal_jump: 1.2,
      elasticity: 0.6,
      jump_delay: 600,
      encumbrance: 0.4,
      z_offset: -3,
      speed: 4,
      contents_offset: [-1, 0, -4],
      animation: "horse_12x11.png",
    }.merge! options

    super(options)
  end

  public
  # Mount the horsie or push off whoever is riding on it.
  def activated_by(actor)
    if carrying?
      drop
    else
      pick_up(actor)
    end
  end

  protected
  # Dismount the horsie.
  def on_having_dropped(object)
    super(object)

    if object.controlled_by_player?
      self.local = (not parent.client?) # Revert to owned by host.
      schedule_jump
    end

    # Buck after the horse drops someone.
    self.z_velocity = 0.8 if self.z == ground_level
  end

  protected
  def on_having_picked_up(object)
    super(object)
    if object.controlled_by_player?
      self.local = object.local? # If you pick up a player, change to its locality.
      stop_timer(:jump)
    end
  end
end

end