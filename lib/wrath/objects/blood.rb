class Blood < StaticObject
  trait :timer

  def initialize(options = {})
    options = {
      elasticity: 0,
      animation: "blood_1x1.png",
    }.merge! options

    super options
  end
end