module Wrath
class WaterDroplet < Droplet
  COLOR = Color.rgba(0, 50, 200, 150)

  def initialize(options = {})
    options = {
      color: COLOR,
    }.merge! options

    super options
  end

  def on_stopped
    destroy
  end
end
end