class RemotePlayer < Player
  attr_reader :socket

  def initialize(socket, options = {})
    options = {
    }.merge! options

    @socket = socket

    super options
  end
end