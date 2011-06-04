module Wrath
  class CraterWithLid < Crater
    public
    def initialize(options = {})
      options = {
          animation: "crater_with_lid_13x8.png",
      }.merge! options

      super options
    end
  end
end