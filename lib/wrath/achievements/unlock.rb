module Wrath
  class Unlock
    include Log

    attr_reader :name, :type, :manager

    def unlocked?; @unlocked; end

    public
    def initialize(type, name, manager, options = {})
      options = {
          title: nil,
          unlocked: false,
      }.merge! options

      @name, @type, @manager = name, type, manager

      @unlocked = options[:unlocked]
      @title = options[:title]

      if @type == :general
        raise ":general unlocks must have a title" if @title.nil?
      else
        raise "non-general unlocks must not have a title" unless @title.nil?
      end

      @manager.add_unlock(self)
    end

    public
    def title
      case @type
        when :priest  then Priest.title(@name)
        when :level   then Level.const_get(@name).to_s
        when :general then @title
        else
          raise "Unknown unlock type: #{@type.inspect}"
      end
    end

    public
    def icon
      case @type
        when :priest  then Priest.icon(@name)
        when :level   then Level.const_get(@name).icon
        when :general
          @icon ||= Image["unlocks/#{name}.png"]
          @locked_icon||= Image["unlocks/locked/#{name}.png"]
          unlocked? ? @icon : @locked_icon
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