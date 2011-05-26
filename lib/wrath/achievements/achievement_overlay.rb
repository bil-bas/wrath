module Wrath
  class AchievementOverlay < GameObject
    include Log
    
    ACHIEVEMENT_COLOR = Color.rgba(0, 200, 0, 100)  
    UNLOCK_COLOR = Color.rgba(0, 0, 255, 100)  
    BORDER_COLOR = Color.rgba(255, 255, 255, 150)
    TITLE_COLOR = Color.rgb(225, 225, 225)    
    
    class Popup < Fidgit::Composite 
      TEXT_WIDTH = 135
      TITLE_FONT_SIZE = 18
      BODY_FONT_SIZE = 15
      ICON_BACKGROUND_COLOR = Color.rgb(0, 0, 50)
      
      class Clock < BasicGameObject
        trait :timer
      end 
      
      DURATION = 8000
      
      def initialize(title, body, icon, options = {})
        options = {
          font: "pixelated.ttf",
          font_size: BODY_FONT_SIZE,
          border_color: BORDER_COLOR,
          border_thickness: 2,
          z: ZOrder::GUI,
        }.merge! options
        
        super(options)
        
        label_options = { z: ZOrder::GUI, font: options[:font], font_size: options[:font_size] }
        
        @packer = pack :horizontal, padding: 0, spacing: 0 do 
          label "", label_options.merge(icon: ScaledImage.new(icon, $window.sprite_scale), padding: 0, border_thickness: 4, border_color: ICON_BACKGROUND_COLOR)            
          pack :vertical, padding: 0, spacing: 0 do
            label title, label_options.merge(color: TITLE_COLOR, font_size: TITLE_FONT_SIZE)
            text_area label_options.merge(width: TEXT_WIDTH, text: body, background_color: Color::NONE)
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

      @popups = Fidgit::VerticalPacker.new(padding: 0, spacing: 4, width: $window.width, height: $window.height)
      
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