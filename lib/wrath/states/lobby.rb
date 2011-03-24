module Wrath
  class Lobby < Gui
    attr_reader :network

    public
    def accept_message?(message); [Message::NewGame].find {|m| message.is_a? m }; end

    public
    def initialize(network, opponent_name, self_name = nil)
      super()

      self_name = settings[:player, :name] unless self_name

      @network, @self_name, @opponent_name = network, self_name, opponent_name

      on_input(:escape) { game_state_manager.pop_until_game_state Menu }

      pack :vertical do
        case @network
          when Server
            label "Lobby - pick a level"

          when Client
            @network.send_msg(Message::ClientReady.new(settings[:player, :name]))
            label "Lobby - wait for host to pick a level"

          else
            label "Lobby"
        end

        label "#{@self_name} vs #{@opponent_name}", y: 15

        # Level-picker.
        unless @network.is_a? Client
          list do
            Play.levels.each do |level|
              item(level.to_s, level) { push_game_state level.new(@network) }
            end
          end
        end
      end
    end

    public
    def update
      super
      @network.update if @network
    end
  end
end