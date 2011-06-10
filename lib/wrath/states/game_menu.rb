module Wrath
  class GameMenu < Gui
    def draw_background?; false; end

    def initialize
      super

      on_input(:"released_#{controls[:general, :menu]}") { @released_button = true }
      @released_button = false
    end

    def setup
      super

      @close_button = controls[:general, :menu]
      on_input(@close_button) { pop_game_state if @released_button }

      vertical background_color: BACKGROUND_COLOR, align: :center do
        options = { width: 300, justify: :center }
        button t.button.resume.text, options.merge(tip: t.button.resume.tip, shortcut: true) do
          pop_game_state
        end

        button t.button.instructions.text, options.merge(tip: t.button.instructions.tip, shortcut: true) do
          push_game_state Instructions
        end

        button t.button.options.text, options.merge(tip: t.button.options.tip, shortcut: true) do
          push_game_state Options
        end

        label ""

        button t.button.quit.text, options do
          previous_game_state.send_message(Message::EndGame.new) if previous_game_state.networked?
          pop_until_game_state Lobby
        end
      end
    end

    def finalize
      super
      input.delete @close_button
    end

    def draw
      previous_game_state.draw
      $window.flush
      super
    end

    def update
      super
      # TODO: Update previous if networked.
    end
  end
end