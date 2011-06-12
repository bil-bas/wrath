module Wrath
  class GameMenu < Fidgit::DialogState
    include ShownOverNetworked

    def self.t; R18n.get.t.gui[Inflector.underscore(Inflector.demodulize(name))]; end
    def t; self.class.t; end
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

      vertical background_color: Gui::BACKGROUND_COLOR, align: :center do
        options = { width: 50, font_size: 5, justify: :center }
        button t.button.resume.text, options.merge(tip: t.button.resume.tip, shortcut: :auto) do
          pop_game_state
        end

        button t.button.instructions.text, options.merge(tip: t.button.instructions.tip, shortcut: :auto) do
          push_game_state Instructions
        end

        button t.button.options.text, options.merge(tip: t.button.options.tip, shortcut: :auto) do
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
      container.clear
      input.delete @close_button
    end
  end
end