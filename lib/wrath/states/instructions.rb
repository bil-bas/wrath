module Wrath
  class Instructions < Gui
    include ShownOverNetworked

    TABS = [:gods, :anger, :maps, :priests, :favour, :interaction, :altar, :font, :winning, :credits]

    def setup
      super

      Gosu::register_entity(:b, Image['gui/bullet.png'])

      on_input([:up, :mouse_wheel_up], :previous_tab)
      on_input([:down, :mouse_wheel_down], :next_tab)
    end

    def next_tab
      return if @tabs_group.value == TABS.last
      @tabs_group.value = TABS[TABS.index(@tabs_group.value) + 1]
    end

    def previous_tab
      return if @tabs_group.value == TABS.first
      @tabs_group.value = TABS[TABS.index(@tabs_group.value) - 1]
    end

    def body
      horizontal spacing: 0, padding: 0 do
        @tabs_group = group do
          @tab_buttons = vertical padding: 0, spacing: 1 do
            TABS.each do |page|
              radio_button(t.tab[page].title, page, border_thickness: 0, width: 40)
            end
          end

          subscribe :changed do |sender, value|
            @body_text.text = t.tab[value].body.gsub('*', '&b;')
            current = @tab_buttons.find {|elem| elem.value == value }
            @tab_buttons.each {|t| t.enabled = (t != current) }
            current.color, current.background_color = current.background_color, current.color
            @scroll_window.offset_y = 0

            @previous_button.enabled = (value != TABS.first)
            @next_button.enabled = (value != TABS.last)
          end
        end

        vertical padding: 0, spacing: 0 do
          @scroll_window = scroll_window width: 130, height: 87, background_color: BACKGROUND_COLOR do
            @body_text = text_area padding: 2, enabled: false, background_color: BACKGROUND_COLOR, width: 125
          end

          horizontal align_h: :center do
            @previous_button = button t.button.previous.text, shortcut: :auto, &:previous_tab
            @next_button = button t.button.next.text, shortcut: :auto, &:next_tab
          end
        end

        @tabs_group.value = TABS.first
      end
    end
  end
end