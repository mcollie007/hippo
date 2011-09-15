module Hippo::TransactionSets
  class Base
    class << self
      attr_accessor :components, :identifier

      def components
        @components ||= []
      end

      def loop_name(id)
        @identifier = id
      end

      def add_component(klass, options={})
        components << Component.new(options.merge(:klass => klass, :sequence => components.length))
      end
      alias segment add_component
      alias loop add_component
    end

    attr_accessor :values, :parent, :sequences

    def initialize(options = {})
      @parent = options.delete(:parent)
    end

    def values
      @values ||= {}
    end

    def increment(segment_identifier)
      @sequences ||= Hash.new(0)

      @sequences[segment_identifier] += 1
    end

    def segment_count
      values.values.map(&:segment_count).inject(&:+)
    end

    def to_s
      output = ''

      values.sort.each do |sequence, component|
        output += component.to_s
      end

      output
    end

    def get_component(identifier, sequence = nil)
      if sequence.nil?
        sequence = 0
      else
        sequence = sequence.to_i - 1
      end

      self.class.components.select do |c|
        c.identifier == identifier
      end[sequence]
    end

    def method_missing(method_name, *args)
      component_name, component_sequence = method_name.to_s.split('_')
      component_entry = get_component(component_name, component_sequence)

      if component_entry.nil?
        raise Hippo::Exceptions::InvalidSegment.new "Invalid segment specified: '#{method_name.to_s}'."
      end

      values[component_entry.sequence] ||= component_entry.initialize_component(self)

      yield values[component_entry.sequence] if block_given?

      values[component_entry.sequence]
    end
  end
end
