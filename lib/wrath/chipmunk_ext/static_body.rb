module CP
  class StaticBody < Body
    def initialize
      super(Float::INFINITY, Float::INFINITY)
    end
  end
end