module Fidgit
  class GuiState
    def finalize
      @mouse_over.publish :leave if @mouse_over
      @mouse_over = nil

      @tool_tip = nil

      nil
    end
  end
end