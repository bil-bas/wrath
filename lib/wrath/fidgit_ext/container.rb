module Fidgit
  class Container < Element
    public
    def with(&block)
      case block.arity
        when 1
          yield self
        when 0
          instance_methods_eval &block
        else
          raise "block arity must be 0 or 1"
      end
    end
  end
end