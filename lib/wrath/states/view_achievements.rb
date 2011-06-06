module Wrath
  class ProgressBar < Fidgit::Label
    BACKGROUND_COLOR = Color.rgb(150, 150, 150)
    BAR_COLOR = Color.rgb(255, 255, 255)
    TEXT_COLOR = Color.rgb(0, 0, 0)

    def initialize(total, required, options = {})
      options = {
          background_color: BACKGROUND_COLOR,
          color: TEXT_COLOR,
          padding_left: 12,
      }.merge! options

      super("#{total.floor} / #{required.floor}", options)

      @progress = [total.to_f / required, 1].min
    end

    def draw_background
      super
      draw_rect(x, y, width * @progress , height, z, BAR_COLOR) if @progress > 0
    end
  end

  class ViewAchievements  < Gui
    ACHIEVEMENT_BACKGROUND_COLOR = Color.rgb(0, 0, 50)
    WINDOW_BACKGROUND_COLOR = Color.rgb(0, 0, 100)

    INCOMPLETE_TITLE_COLOR = Color.rgb(150, 150, 150)
    COMPLETE_TITLE_COLOR = Color.rgb(0, 255, 0)
    UNLOCK_BACKGROUND_COLOR = Color.rgb(50, 50, 50)
    
    TIME_FORMAT = "%F %H:%M" # 2007-11-19 08:37

    def initialize
      super

      add_inputs(
          b: :pop_game_state,
          escape: :pop_game_state
      )

      vertical do
        horizontal padding: 0 do |packer|
          packer.label "Achievements", font_size: 32
          completed = achievement_manager.achievements.count {|a| a.complete? }
          ProgressBar.new(completed, achievement_manager.achievements.size,
                                    parent: packer, width: $window.width - 500, font_size: 32)
        end

        scroll_window width: $window.width - 50, height: $window.height - 150, background_color: WINDOW_BACKGROUND_COLOR do
          vertical spacing: 5 do
            complete, incomplete = achievement_manager.achievements.partition {|a| a.complete?}
            complete.each {|achieve| achievement(achieve) }
            incomplete.each {|achieve| achievement(achieve) }
          end
        end

        horizontal padding: 0 do
          button("(B)ack") { pop_game_state }

          toggle_button("Disable unlocks", tip: "Allow use of all features, even if they are locked, until game is restarted", value: achievement_manager.unlocks_disabled?) do |sender, value|
            achievement_manager.unlocks_disabled = value
          end

          button "Reset statistics", tip: "Resets all statistics, achievements and unlocks PERMANENTLY" do |sender|
            achievement_manager.reset
            switch_game_state self.class
          end
        end
      end
    end
    
    protected
    def achievement(achieve)
      horizontal padding: 4, spacing: 0, background_color: ACHIEVEMENT_BACKGROUND_COLOR do
        label "", icon: ScaledImage.new(achieve.icon, sprite_scale * 1.5),
            border_thickness: 4, border_color: Color::BLACK, padding: 0

        vertical padding: 0, spacing: 0 do
          horizontal padding: 0, spacing: 0 do |packer|
            # title
            color = achieve.complete? ? COMPLETE_TITLE_COLOR : INCOMPLETE_TITLE_COLOR
            packer.label achieve.title, width: 380, font_size: 20, color: color

            # Progress bar, if needed.
            if achieve.complete?
              completed_at = achievement_manager.completion_time(achieve.name).strftime(TIME_FORMAT)
              packer.label completed_at, font_size: 15, padding_left: 0
            else
              ProgressBar.new(achieve.total, achieve.required,
                      parent: packer, width: $window.width - 625, height: 20, font_size: 15)
            end
          end

          # Description of what has been done.
          text_area text: achieve.description, font_size: 15, width: $window.width - 225,
              background_color: ACHIEVEMENT_BACKGROUND_COLOR, enabled: false

          unless achieve.unlocks.empty?
            horizontal padding: 0, spacing: 4 do
              achieve.unlocks.each do |unlock|
              icon = ScaledImage.new(unlock.icon, sprite_scale * 0.75)
              title = unlock.unlocked? ? "Unlocked" : "Locked"
              label "", icon: icon, tip: "#{title}: #{unlock.title}", background_color: UNLOCK_BACKGROUND_COLOR
              end
            end
          end
        end
      end
    end
  end
end