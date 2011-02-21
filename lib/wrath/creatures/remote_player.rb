# encoding: utf-8

class RemotePlayer < Player
  IMAGE_ROW = 1

  attr_reader :socket

  def initialize(socket, options = {})
    options = {
    }.merge! options

    @socket = socket

    super IMAGE_ROW, options
  end
end