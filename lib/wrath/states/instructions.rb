module Wrath
  class Instructions < Gui
    TABS = [:gods, :priests, :favour]

    def setup
      super

      vertical do
        label t.title, font_size: 32

        Gosu::register_entity(:bullet, Image['gui/bullet.png'])

        vertical spacing: 0, padding: 0 do
          @tabs_group = group do
            @tab_buttons = horizontal padding: 0, spacing: 5 do
              TABS.each do |page|
                radio_button(t.tab[page].title, page, border_thickness: 0)
              end
            end

            subscribe :changed do |sender, value|
              @body_text.text = t.tab[value].body.gsub('*', '&bullet;')
              current = @tab_buttons.find {|elem| elem.value == value }
              @tab_buttons.each {|t| t.enabled = (t != current) }
              @scroll_window.offset_y = 0
            end
          end

          @scroll_window = scroll_window width: $window.width - 40, height: $window.height - 180, background_color: BACKGROUND_COLOR do
            @body_text = text_area padding: 10, enabled: false,
                                   width: $window.width - 75
          end

          @tabs_group.value = TABS.first
        end

        button(t.button.back.text, shortcut: :auto) { pop_game_state }
      end
    end
  end
end