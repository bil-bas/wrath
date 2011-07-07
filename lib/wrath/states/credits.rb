module Wrath
  class Credits < Gui
    def setup
      Gosu::register_entity(:b, Image['gui/bullet.png'])
      Dir[File.join(EXTRACT_PATH, 'media/images/credits/*.*')].each do |file|
        file = File.basename file
        Gosu::register_entity(file.chomp(File.extname(file)), Image["credits/#{file}"])
      end
      super
    end

    def body
      scroll_window width: $window.width - 10, height: 87, background_color: BACKGROUND_COLOR do
        text_area text: t.body.gsub('*', '&b;'), width: $window.width - 16, enabled: false
      end
    end
  end
end