module Wrath
  class Instructions < Gui
    include ShownOverNetworked

    TABS = [:gods, :priests, :favour]

    def setup
      super

      Gosu::register_entity(:bullet, Image['gui/bullet.png'])
    end

    def body
      vertical spacing: 0, padding: 0 do
        @tabs_group = group do
          @tab_buttons = horizontal padding: 0, spacing: 1.25 do
            TABS.each do |page|
              radio_button(t.tab[page].title, page, border_thickness: 0)
            end
          end

          subscribe :changed do |sender, value|
            @body_text.text = t.tab[value].body.gsub('*', '&bullet;')
            current = @tab_buttons.find {|elem| elem.value == value }
            @tab_buttons.each {|t| t.enabled = (t != current) }
            current.color, current.background_color = current.background_color, current.color
            @scroll_window.offset_y = 0
          end
        end

        @scroll_window = scroll_window width: $window.width - 10, height: $window.height - 45, background_color: BACKGROUND_COLOR do
          @body_text = text_area padding: 2, font_size: 5.25, enabled: false, background_color: BACKGROUND_COLOR,width: $window.width - 18
        end

        @tabs_group.value = TABS.first
      end
    end
  end
end