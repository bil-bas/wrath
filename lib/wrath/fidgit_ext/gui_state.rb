module Fidgit
  class GuiState
    extend Forwardable

    def_delegators :@container, :horizontal, :vertical, :grid
  end
end