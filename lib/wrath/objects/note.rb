module Wrath
class Note < StaticObject
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
      encumbrance: 0,
      elasticity: 1,
      factor: 0.7,
      color: Color.rgba(*COLORS[index], INITIAL_ALPHA),
      animation: "note_5x4.png",
      collision_type: :scenery,
    }.merge! options

    Sample["note_#{index + 1}.wav"].play(VOLUME)

    super options

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