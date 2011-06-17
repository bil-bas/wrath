module Wrath
  class Chat < Fidgit::DialogState
    @@body_text = ''

    def host?; true; end

    def setup
      super

      vertical do
        @body = text_area text: @@body_text, enabled: false, height: 80, width: $window.width / 2, background_color: Color.rgba(0, 0, 0, 0) do
          subscribe :changed do |sender, text|
            @@body_text = text
          end
        end

        @entry = text_area height: 5, width: $window.width / 2
      end

      self.focus = @entry

      on_input(controls[:general, :chat]) do
        str = @entry.text.strip
        unless str.empty?
          message = Message::Say.new((host? ? 0 : 1), str)
          message.process
          #previous_game_state.send_message(message)
        end

        pop_game_state
      end
    end



    def update
      previous_game_state.update unless previous_game_state.is_a? Gui
      super
      @entry.focus(self)
    end

    def draw
      previous_game_state.draw
      super
    end
  end
end