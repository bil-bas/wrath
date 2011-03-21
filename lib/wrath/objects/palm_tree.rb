module Wrath
  class PalmTree < Tree
    def initialize(options = {})
      options = {
          radius: 6,
          animation: "palm_tree_16x16.png",
          factor: 1,
      }.merge! options

      super(options)
    end
  end
end