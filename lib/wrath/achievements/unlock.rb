module Wrath
  class Unlock
    include Log

    attr_reader :name, :title, :type, :image, :manager

    def unlocked?; @unlocked; end

    public
    def initialize(type, name, manager, options = {})
      options = {
          unlocked: false
      }.merge! options

      @name, @type, @manager = name, type, manager

      @unlocked = options[:unlocked]

      eval_type

      @manager.add_unlock(self)
    end

    protected
    def eval_type
      case @type
        when :priest
          @image = Priest.icon(@name)
          @title = Priest.title(@name)

        when :level
          level = Level.const_get(@name)
          @image = level.icon
          @title = level.to_s

        else
          raise "Unknown unlock type: #{@type.inspect}"
      end
    end

    public
    def unlock
      log.info { "Unlocked: #{@type.inspect} / #{@name.inspect}" }
      @unlocked = true
    end
  end
end