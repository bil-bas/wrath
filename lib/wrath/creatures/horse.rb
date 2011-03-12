# encoding: utf-8

class Horse < Mob
  def favor; 20; end
  def mount?; true; end

  def initialize(options = {})
    options = {
      vertical_jump: 0.1,
      horizontal_jump: 0.1,
      elasticity: 0.6,
      jump_delay: 2000,
      encumbrance: 0.4,
      z_offset: -3,
      speed: 4,
      animation: "horse_12x11.png",
    }.merge! options

    super(options)
  end

  # Mount the horsie.
  def activate(actor)
    stop_timer(:jump)
    actor.drop
    actor.player.avatar = self
    pick_up(actor)
  end

  # Dismount the horsie.
  def drop
    rider = carrying
    super
    player.avatar = rider
    self.z_velocity = 0.8
    schedule_jump
  end
end