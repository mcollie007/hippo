require 'hippo'

module Hippo
  class Parser
    include Hippo::Separator

    attr_accessor :transaction_sets, :raw_data

    def initialize(options={})
      setup_separators(options)
    end

    def read_string(input)
      @raw_data = input
      remove_base_control_characters
      parse_separators(@raw_data)
    end

    def read_file(filename)
      @raw_data = File.read(filename)
      remove_base_control_characters
      parse_separators(@raw_data)
    end

    def remove_base_control_characters
      @raw_data.gsub!(/[\a\e\f\n\r\t\v]/,'')
    end

    def initialize_segment(input)
      fields = input.split(@field_separator)

      segment_identifier = fields.shift
      segment = Segments.const_get(segment_identifier.upcase).new

      fields.each_with_index do |value, index|
        field = segment.class.fields[index]

        # if the field is an array that means it is a
        # composite field
        if field.class == Array
          composite_fields    = value.split(@composite_separator)
          composite_sequence  = field.first.composite_sequence

          segment.values[composite_sequence] = {}

          composite_fields.each_with_index do |comp_value, comp_index|
            composite_field = field[comp_index]

            segment.values[composite_sequence][composite_field.sequence] = comp_value
          end
        else
          segment.values[field.sequence] = value
        end
      end

      segment
    end

    def find_first_segment(segments, identifier, reverse = false)
      segments.reverse! if reverse

      if index = segments.index{|o| o.identifier == identifier}
        segments[index]
      else
        nil
      end
    end

    def populate_transaction_sets
      raw_transaction_sets  = []
      segments              = []
      inside_transaction    = false

      @raw_data.split(@segment_separator).each do |segment_string|
        next if segment_string.strip.empty?

        segments << initialize_segment(segment_string)
      end

      segments.each_with_index do |segment, index|

        if segment.identifier == 'ST'
          raw_transaction_sets << {:segments  => [],
                                   :ISA       => find_first_segment(segments[0,index + 1], 'ISA', true),
                                   :GS        => find_first_segment(segments[0,index + 1], 'GS', true),
                                   :GE        => find_first_segment(segments[index + 1,segments.length - index + 1], 'GE'),
                                   :IEA       => find_first_segment(segments[index + 1,segments.length - index + 1], 'IEA')}

          inside_transaction = true
        end

        raw_transaction_sets.last[:segments] << segment if inside_transaction

        inside_transaction = false if segment.identifier == 'SE'
      end

      raw_transaction_sets.collect do |transaction|
        transaction_set_id = transaction[:segments].first.ST01
        transaction_set = Hippo::TransactionSets.constants.select{|c| c.to_s.end_with?(transaction_set_id) }.first

        Hippo::TransactionSets.const_get(transaction_set)::Base.new(separators.merge(transaction))
      end
    end

    def parse_file(filename)
      read_file(filename)
      populate_transaction_sets
    end
    alias :parse :parse_file

    def parse_string(input)
      read_string(input)
      populate_transaction_sets
    end
  end
end

if __FILE__ == $0
  parser = Hippo::Parser.new
  parser.parse(ARGV[0])

  output_string = ''
  parser.segments.each do |seg|
    output_string += seg.to_s
  end

  puts ''
  puts output_string
end
