require 'pp'
require 'hippo'

module Hippo
  class Parser
    attr_accessor :segments, :raw_data, :field_separator, :segment_separator, :composite_separator, :repetition_separator

    def initialize(options={})
      @field_separator      = options.delete(:field_separator)      || Hippo::FieldSeparator
      @segment_separator    = options.delete(:segment_separator)    || Hippo::SegmentSeparator
      @composite_separator  = options.delete(:composite_separator)  || Hippo::CompositeSeparator
      @repetition_separator = options.delete(:repetition_separator) || Hippo::RepetitionSeparator

      @segments             = options.delete(:segments)             || []
      @raw_data             = options.delete(:data)                 || options.delete(:raw_data)
    end

    def segments
      @segments ||= []
    end

    def read_file(filename)
      @raw_data = File.read(filename)
    end

    def populate_segments

      @raw_data.split(@segment_separator).each do |line|

        line = line.strip
        next if line.nil? || line.empty?

        fields = line.split(@field_separator)

        # grab the first field as it is the segment identifier 
        segment_identifier = fields.shift

        # create a new segment object based on the identifier
        segment = Hippo::Segments.const_get(segment_identifier.upcase).new

        # populate each field from the original input
        fields.each_with_index do |value, index|
          field = segment.class.fields[index]

          # if the field is an array that means it is a
          # composite field
          if field.class == Array
            composite_fields = value.split(@composite_separator)

            segment.values[index] = {}

            composite_fields.each_with_index do |comp_value, comp_index|
              segment.values[index][field[comp_index].sequence] = comp_value
            end
          else
            segment.values[field.sequence] = value
          end
        end

        segments << segment
      end

      segments
    end

    def populate_transaction_sets
      segments_by_transaction_set = []

      @segments.each do |segment|
        if segment.class == Hippo::Segments::ST
          segments_by_transaction_set << []
        end

        segments_by_transaction_set.last << segment if segments_by_transaction_set.last
      end

      segments_by_transaction_set.collect do |transaction_segments|
        transaction_set_id = transaction_segments.first.ST01
        puts Hippo::TransactionSets.constants.inspect

        transaction_set = Hippo::TransactionSets.constants.select{|c| c.to_s.end_with?(transaction_set_id) }.first

        Hippo::TransactionSets.const_get(transaction_set)::Base.new(:segments => transaction_segments)
      end
    end

    def parse(filename)
      read_file(filename)
      populate_segments
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
