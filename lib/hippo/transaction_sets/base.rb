module Hippo::TransactionSets
  class Base
    include Hippo::Separator

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
      @parent               = options[:parent]

      setup_separators(options)

      populate options[:segments] if options[:segments]
    end

    def populate(segments)
      self.class.components.each_with_index do |component, component_index|
        if component.klass.ancestors.include? Hippo::Segments::Base
          # segments
          segments_found = []

          segments.each do |segment|
            next unless component.valid? segment

            if component.repeating?
              values[component.sequence] ||= component.initialize_component(self)
              values[component.sequence] << segment
            else
              values[component.sequence] = segment
            end

            segments_found << segment
          end

          segments_found.each {|s| segments.delete(s)}
        else
          # loops
          while true do
            found_next_segment  = false
            starting_index      = nil
            length              = 0

            segments.each_with_index do |segment, segment_index|
              next unless component.valid? segment

              starting_index = segment_index
            end

            # if we don't find anything break out of the loop
            break unless starting_index

            remaining_components = self.class.components.slice(component_index + 1, self.class.components.length - 1)

            remaining_components.each do |next_component|
              break if found_next_segment
              length = 0

              segments.each_with_index do |segment, segment_index|
                found_next_segment = next_component.valid? segment
                break if found_next_segment

                length += 1
              end
            end

            length = segments.length - starting_index if length == 0

            subcomponent = component.initialize_component(self)
            subcomponent.populate(segments.slice!(starting_index, length))

            if component.repeating?
              values[component.sequence] = component.initialize_component(self)
              values[component.sequence] << subcomponent
            else
              values[component.sequence] = subcomponent
            end
          end
        end
      end

      puts "Remaining Segments(#{self.class.identifier}): " + segments.inspect unless segments.empty?
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
      component = get_component(component_name, component_sequence)

      if component.nil?
        raise Hippo::Exceptions::InvalidSegment.new "Invalid segment specified: '#{method_name.to_s}'."
      end

      values[component.sequence] ||= component.initialize_component(self)

      yield values[component.sequence] if block_given?

      values[component.sequence]
    end
  end
end
