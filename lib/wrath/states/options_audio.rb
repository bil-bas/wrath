module Wrath
  class OptionsAudio < Gui
    SLIDER_WIDTH = 200

    def initialize
      super

      on_input([:escape, :b], :pop_game_state)

      pack :vertical do
        label "Options  |  Audio", font_size: 32

        pack :grid, num_columns: 4, padding: 0 do
          # MASTER
          label "Master volume"
          @master_slider = slider width: SLIDER_WIDTH,  range: 0.0..1.0 do |sender, value|
            Window.volume = value
            settings[:audio, :master_volume] = value
            @master_percentage.text = "#{(value * 100).round}%"
          end
          @master_percentage = label "100%", justify: :right
          @master_slider.value = Window.volume
          label "" # No test option for global.

          # EFFECTS
          label "Effects volume"
          @effects_slider = slider width: SLIDER_WIDTH, range: 0.0..1.0 do |sender, value|
            Sample.volume = value
            settings[:audio, :effects_volume] = value
            @effects_percentage.text = "#{(value * 100).round}%"
          end
          @effects_percentage = label "100%", justify: :right
          @effects_slider.value = Sample.volume

          button("Test") { Sample["objects/rock_sacrifice.ogg"].play }

          # MUSIC
          label "Music volume"
          label "(Not implemented)"
=begin

          music_slider = slider width: SLIDER_WIDTH, range: 0.0..1.0, enable: false do |sender, value|
            Song.volume = value
            settings[:audio, :music_volume] = value
            @music_percentage.text = "#{(value * 100).round}%"
          end
          @music_percentage = label "100%", justify: :right
          #music_slider.value = Song.volume
=end
        end

        pack :horizontal, padding: 0 do
          button("(B)ack") { pop_game_state }
          button("Defaults") do
            @master_slider.value = 0.5
            @effects_slider.value = 1.0
          end
        end
      end
    end
  end
end