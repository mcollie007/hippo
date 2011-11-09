require 'hippo'

module Hippo
  class Parser
    include Hippo::Separator

    attr_accessor :transaction_sets, :raw_data

    def initialize(options={})
      setup_separators(options)
    end

    def read_file(filename)
      @raw_data = File.read(filename)
      parse_separators(@raw_data)
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

    def populate_transaction_sets
      raw_transaction_sets = []

      @raw_data.split(@segment_separator).each do |segment_string|
        next if segment_string.strip.empty?

        if segment_string =~ /\AST/
          raw_transaction_sets << []
        end

        raw_transaction_sets.last << initialize_segment(segment_string)
      end

      raw_transaction_sets.collect do |segments|
        transaction_set_id = segments.first.ST01
        transaction_set = Hippo::TransactionSets.constants.select{|c| c.to_s.end_with?(transaction_set_id) }.first

        Hippo::TransactionSets.const_get(transaction_set)::Base.new(separators.merge(:segments => segments))
      end
    end

    def parse(filename)
      read_file(filename)
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
