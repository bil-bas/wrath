module Fidgit
  class Container < Element
    public
    # Evaluate a block, just like it was a constructor block.
    def with(&block)
      raise ArgumentError.new("Must pass a block") unless block_given?
      case block.arity
        when 1
          yield self
        when 0
          instance_methods_eval &block
        else
          raise "block arity must be 0 or 1"
      end
    end

    public
    # Pack elements within the block horizontally.
    def horizontal(options = {}, &block)
      HorizontalPacker.new({ parent: self }.merge!(options), &block)
    end

    public
    # Pack elements within the blockvertically.
    def vertical(options = {}, &block)
      VerticalPacker.new({ parent: self }.merge!(options), &block)
    end

    public
    # Pack elements within the block in a grid (matrix) formation.
    def grid(options = {}, &block)
      GridPacker.new({ parent: self }.merge!(options), &block)
    end
  end
end