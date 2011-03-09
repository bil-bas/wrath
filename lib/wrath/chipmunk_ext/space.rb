module CP
  class Space
    # Collision between a and b.
    def on_collision(a, b)
      raise "requires block" unless block_given?

      a, b = Array(a), Array(b)

      a.each do |c|
        b.each do |d|
          add_collision_func(c, d) do |a, b|
            yield a.owner, b.owner
          end
        end
      end
    end
  end
end