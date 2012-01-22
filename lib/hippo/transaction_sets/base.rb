module Hippo::TransactionSets
  class Base
    include Hippo::Separator
    include Hippo::Parser::TransactionSet
    include Hippo::Outputters::HTML::TransactionSet
    include Hippo::Outputters::PDF::TransactionSet

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

    attr_accessor :values, :parent, :sequences, :ISA, :GS, :GE, :IEA

    def initialize(options = {})
      @parent = options[:parent]
      @ISA    = options[:ISA]
      @GS     = options[:GS]
      @GE     = options[:GE]
      @IEA    = options[:IEA]

      super

      populate(options[:segments]) if options[:segments]
    end

    def populate(segments)
      self.class.components.each_with_index do |component, component_index|
        if component.klass.ancestors.include? Hippo::Segments::Base
          # segments
          while true do
            segment = segments.first

            break unless segment
            break unless component.valid?(segment)

            segment.parent = self

            if component.repeating?
              values[component.sequence] ||= component.initialize_component(self)
              values[component.sequence] << segment
            else
              values[component.sequence] = segment
            end

            segments.delete(segment)
          end
        else
          # loops
          while true do
            initial_segment = segments.first

            break unless initial_segment
            break unless component.valid?(initial_segment)

            ending_index    = nil
            starting_index  = component.repeating? ? component_index : component_index + 1
            remaining_components = self.class.components.slice(starting_index, self.class.components.length - starting_index)
            remaining_components.each do |next_component|
              break if ending_index

              ending_index = segments.find_index{|segment| segment != segments.first && next_component.valid?(segment)}
            end

            child_segments = segments.slice!(0, ending_index || segments.length)
            values[component.sequence] ||= component.initialize_component(self)
            if component.repeating?
              values[component.sequence].build {|comp| comp.populate(child_segments) }
            else
              values[component.sequence].populate(child_segments)
            end
          end
        end
      end

      unless segments.empty?
        raise Hippo::Exceptions::ParseError.new "Remaining Segments for #{self.class.identifier} after parsing was completed. Segments remaining: \n" + segments.map(&:to_s).join("\n")
      end
    end

    def values
      @values ||= {}
    end

    def increment(segment_identifier)
      @sequences ||= Hash.new(0)

      @sequences[segment_identifier] += 1
    end

    def segments
      values.values.collect(&:segments).flatten
    end

    def segment_count
      segments.count
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

    def get_component_by_name(name, sequence = nil)
      sequence =  if sequence.nil?
                    0
                  else
                    sequence.to_i - 1
                  end

      self.class.components.select do |c|
        if name.class == Regexp
          c.options[:name] =~ name
        else
          c.options[:name] == name
        end
      end[sequence]
    end

    def method_missing(method_name, *args)
      component = if method_name == :find_by_name
                    get_component_by_name(args[0], args[1])
                  else
                    component_name, component_sequence = method_name.to_s.split('_')
                    get_component(component_name, component_sequence)
                  end

      if component.nil?
        raise Hippo::Exceptions::InvalidSegment.new "Invalid segment specified: '#{method_name.to_s}'."
      end

      values[component.sequence] ||= component.initialize_component(self)

      yield values[component.sequence] if block_given?

      values[component.sequence]
    end
  end
end
