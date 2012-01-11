module Hippo::TransactionSets
  class RepeatingComponent < Array
    def initialize(component_entry, parent)
      @component_entry = component_entry
      @parent = parent
    end

    def build
      component = @component_entry.populate_component(@component_entry.klass.new(:parent => @parent))

      push(component)
      yield component if block_given?
      component
    end

    def to_s
      self.map(&:to_s).join
    end

    def segment_count
      return 0 unless self.length != 0

      self.map(&:segment_count).inject(&:+)
    end

    def method_missing(method_name, *args, &block)
      build if self.length == 0

      self.first.send(method_name, *args, &block)
    end
  end
end
