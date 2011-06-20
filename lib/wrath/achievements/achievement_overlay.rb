module Wrath
  class AchievementOverlay < GameObject
    include Log
    
    ACHIEVEMENT_COLOR = Color.rgba(0, 200, 0, 100)  
    UNLOCK_COLOR = Color.rgba(0, 0, 255, 100)  
    BORDER_COLOR = Color.rgba(255, 255, 255, 150)
    TITLE_COLOR = Color.rgb(225, 225, 225)    
    
    class Popup < Fidgit::Composite 
      TEXT_WIDTH = 135
      TITLE_FONT_HEIGHT = 18
      BODY_FONT_HEIGHT = 15
      ICON_BACKGROUND_COLOR = Color.rgb(0, 0, 50)
      
      class Clock < BasicGameObject
        trait :timer
      end 
      
      DURATION = 8000
      
      def initialize(title, body, icon, options = {})
        options = {
          font_name: $window.class::FONT,
          font_height: BODY_FONT_HEIGHT,
          border_color: BORDER_COLOR,
          border_thickness: 2,
          z: ZOrder::GUI,
        }.merge! options
        
        super(options)
        
        label_options = { z: ZOrder::GUI, font_name: options[:font_name], font_height: options[:font_height] }
        
        @packer = horizontal padding: 4, spacing: 4 do
          image_frame icon, factor: 4, padding: 4, z: ZOrder::GUI, background_color: ICON_BACKGROUND_COLOR

          vertical padding: 0, spacing: 0 do
            label title, label_options.merge(color: TITLE_COLOR, font_height: TITLE_FONT_HEIGHT)
            text_area label_options.merge(width: TEXT_WIDTH, padding_left: 0, text: body, background_color: Color::NONE)
          end
          
        end
        
        start_clock
      end
      
      def start_clock
        @clock = Clock.new
        @clock.after(DURATION) { parent.remove(self) }
      end 

      def update
        @clock.update_trait
        super
      end      
    end
    
    def initialize(manager, options = {})
      super(options)

      @popups = Fidgit::Vertical.new(padding: 0, spacing: 4, width: $window.width, height: $window.height)
      
      manager.subscribe :on_achievement_gained do |sender, achievement|
        add_popup("Complete!", achievement.title, achievement.icon, ACHIEVEMENT_COLOR)
        log.debug { "Showed achievement popup #{achievement.name.inspect}" }
      end
      
      manager.subscribe :on_unlock_gained do |sender, unlock|
        add_popup("Unlocked!", unlock.title, unlock.icon, UNLOCK_COLOR)
        log.debug { "Showed unlocked popup #{unlock.name.inspect}" }
      end
    end
    
    def add_popup(title, body, icon, color)
      Popup.new(title, body, icon, background_color: color, parent: @popups)
    end
    
    def update       
      @popups.update         
      super
    end
    
    def draw
      @popups.draw
    end
  end
end