module Wrath
  class OptionsAudio < Gui
    SLIDER_WIDTH = 300

    def initialize
      super

      on_input([:escape, :b], :pop_game_state)

      vertical do
        label "Options  |  Audio", font_size: 32

        grid num_columns: 4, padding: 0 do
          # MASTER
          label "Master"
          @master_slider = slider width: SLIDER_WIDTH,  range: 0.0..1.0 do |sender, value|
            $window.volume = value
            settings[:audio, :master_volume] = value
            @master_percentage.text = "#{(value * 100).round}%"
          end
          @master_percentage = label "100%"
          @master_slider.value = $window.volume
          @mute_button = toggle_button("Mute", value: $window.muted?) do |sender, value|
            if value
              $window.mute
            else
              $window.unmute
            end
            settings[:audio, :muted] = value
          end

          # EFFECTS
          label "Effects"
          @effects_slider = slider width: SLIDER_WIDTH, range: 0.0..1.0 do |sender, value|
            Sample.volume = value
            settings[:audio, :effects_volume] = value
            @effects_percentage.text = "#{(value * 100).round}%"
          end
          @effects_percentage = label "100%"
          @effects_slider.value = Sample.volume

          button("Play") { Sample["objects/explosion.ogg"].play }

          # MUSIC
          label "Music"
          @music_slider = slider width: SLIDER_WIDTH, range: 0.0..1.0 do |sender, value|
            Song.volume = value
            settings[:audio, :music_volume] = value
            @music_percentage.text = "#{(value * 100).round}%"
          end
          @music_percentage = label "100%"
          @music_slider.value = Song.volume

          #@song = Song["Simply dance - Libra @4_00.ogg"]

          #@play_song_button = button("Play") { @song.playing? ? @song.stop : @song.play }
        end

        horizontal padding: 0 do
          button("(B)ack") { pop_game_state }
          button("Defaults", tip: "Reset to default values") do
            @master_slider.value = 0.5
            @effects_slider.value = 1.0
            @music_slider.value = 1.0
            @mute_button.value = false
          end
        end
      end
    end

    def update
      super
      #@play_song_button.text = @song.playing? ? "Stop" : "Play"
    end

    def pushed
      log.info { "Started editing audio settings" }
    end

    def popped
      log.info { "Stopped editing audio settings" }
      #@song.stop
    end
  end
end