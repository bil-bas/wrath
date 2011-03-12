class BloodDroplet < Droplet
  COLOR = Color.rgb(255, 0, 0)

  def initialize(options = {})
    options = {
      color: COLOR,
    }.merge! options

    super options
  end
end