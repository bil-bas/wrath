module Wrath
  module HasStatus
    attr_reader :statuses

    def self.included(base)
      base.send :include, Fidgit::Event
      base.event :on_applied_status # [self, Status]
      base.event :on_removed_status # [self, Status]
    end

    @@status_types = {}

    # For each status, add a query method.
    # E.g. If there is a Wrath::Status::Poisoned class, there will be a poisoned? method.
    Status.constants.each do |status|
      klass = Status.const_get(status)
      if klass.is_a? Class and klass.ancestors.include? Status
        type = klass.type
        @@status_types[type] = klass
        define_method("#{type}?") do
          not status(type).nil?
        end
      end
    end

    def valid_status?(type); @@status_types.has_key? type; end

    def initialize(*args)
      @statuses = []
      super(*args)
    end

    # Get the status of this type, if any.
    def status(type)
      @statuses.find {|s| s.type == type }
    end

    def apply_status(type, options = {})
      existing_status = status(type)
      if existing_status
        existing_status.reapply(options)
      else
        status = @@status_types[type].new(self, options)
        parent.send_message(Message::ApplyStatus.new(self, status)) if parent.host?

        @statuses << status
        @statuses.sort_by {|s| s.type }

        publish :on_applied_status, status
      end
    end

    def remove_status(type)
      return unless status(type)

      status = @statuses.delete status(type)
      parent.send_message(Message::RemoveStatus.new(self, status)) if parent and parent.host?
      status.remove

      publish :on_removed_status, status
    end

    def update
      @statuses.each(&:update_trait)
      @statuses.each(&:update)
      super
    end

    def draw
      super
      @statuses.each(&:draw)
    end
  end
end