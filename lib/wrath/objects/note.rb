module Wrath
class Note < DynamicObject
  VOLUME = 0.6
  INITIAL_ALPHA = 200

  # Possible colours of notes.
  COLORS = [
      [255, 0, 0],
      [0, 255, 0],
      [0, 0, 255],
  ]

  def initialize(options = {})
    index = rand(COLORS.size)

    options = {
      id: nil,
      encumbrance: 0,
      elasticity: 1,
      factor: 0.7,
      color: Color.rgba(*COLORS[index], INITIAL_ALPHA),
      animation: "note_5x4.png",
      collision_type: :scenery,
    }.merge! options

    super options

    Sample["objects/note_#{index + 1}.ogg"].play_at_x(x, VOLUME)

    @alpha_float = alpha
  end

  def update
    self.z += frame_time / 170.0
    @alpha_float -= frame_time / 17.0
    self.alpha = @alpha_float.to_i
    if alpha == 0
      destroy
    end
  end
end
end