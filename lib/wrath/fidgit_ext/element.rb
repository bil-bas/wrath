module Fidgit
  class Element
    def enabled=(value)
      if @mouse_over and enabled? and not value
        publish :leave
      end

      @enabled = value
    end
  end
end