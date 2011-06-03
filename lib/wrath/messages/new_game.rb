module Wrath
class Message
  # Sent by the server to leave the lobby and start a new game.
  class NewGame < Message

    public
    def initialize(level, god)
      @level, @god = level, god
    end

    protected
    def action(state)
      raise "Bad level passed, #{@level}" unless @level != Level and @level.ancestors.include? Level
      raise "Bad god passed, #{@god}" unless @god != God and @god.ancestors.include? God

      state.new_game(@level, @god)
    end
  end
end
end