class Note < StaticObject
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
    }.merge! options

    Sample["note_#{index + 1}.wav"].play

    super options
  end

  def update
    self.z += 0.1
    self.alpha -= 1
    if alpha == 0
      destroy
    end
  end
end