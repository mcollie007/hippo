module Hippo::Segments
  class Base
    include Hippo::Separator
    include Hippo::Outputters::HTML::Segment
    include Hippo::Outputters::PDF::Segment

    class << self
      attr_accessor :fields, :identifier, :fixed_width

      def fields
        @fields ||= []
      end

      def identifier
        @identifier ||= ''
      end

      def field(field)
        f = Hippo::Field.new
        f.sequence = fields.length + 1
        f.name = field[:name]
        f.datatype = field[:datatype]
        f.minimum  = field[:minimum]
        f.maximum  = field[:maximum]
        f.options = field[:options]
        f.restrictions = field[:restrictions]
        f.separator = field[:separator] || @default_separator || :field_separator

        if @composite_block
          f.composite = true
          f.composite_sequence = fields.length
          f.sequence = fields.last.length + 1
          fields.last << f
        else
          fields << f
        end
      end

      def composite_field(field_name)
        @composite_block = true
        @default_separator = :composite_separator
        fields << []
        yield
        @default_separator = :field_separator
        @composite_block = false
      end

      def segment_identifier(id)
        @identifier = id
      end

      def segment_fixed_width
        @fixed_width = true
      end
    end

    attr_accessor :values, :parent

    # make totaling segment counts easier...
    def segment_count
      1
    end

    def initialize(options = {})
      @parent = options.delete(:parent)

      setup_separators(options)
    end

    def values
      @values ||= {}
    end

    def get_field_name(text)
      text.to_s.gsub(' ','').gsub('=','')
    end

    def get_field(field)
      if field =~ /\A#{self.class.identifier}(?:(\d+)(?:_(\d+)){0,1})\z/
        if $2 && self.class.fields[$1.to_i - 1].class == Array
          self.class.fields[$1.to_i - 1][$2.to_i - 1]
        else
          self.class.fields[$1.to_i - 1]
        end
      else
        fields = self.class.fields.flatten.select{|f| f.name == field.gsub(/_\d{1,2}\z/,'')}

        if field =~ /_(\d{1,2})\z/
          fields[$1.to_i - 1]
        else
          fields.first
        end
      end
    end

    def to_s
      output = self.class.identifier + @field_separator

      self.class.fields.each_with_index do |field, index|
        if field.class == Array # this is a composite field
          field.each do |comp_field|
            field_value = if values[comp_field.composite_sequence]
                            # some values exist for this composite field
                            values[comp_field.composite_sequence][comp_field.sequence].to_s
                          else
                            # no values exist for the entire composite field
                            ''
                          end
            field_value = field_value.ljust(comp_field.maximum) if self.class.fixed_width

            output += field_value + @composite_separator
          end

          output += @field_separator
        else # standard field
          field_value = values[field.sequence].to_s
          field_value = field_value.ljust(field.maximum) if self.class.fixed_width

          output += field_value + @field_separator
        end
      end

      # remove extra field separators that aren't needed
      unless self.class.identifier == 'ISA'
        output = output.gsub(/:{2,}\*/,'*').gsub(/:\*/,'*')
      end

      output += @segment_separator
      output = output.gsub(/\*+~/,'~')
    end

    def identifier
      self.class.identifier
    end

    def method_missing(method_name, *args)
      values

      field = get_field(get_field_name(method_name.to_s))

      if field.nil? || field.class == Array
         raise Hippo::Exceptions::InvalidField.new("Invalid field '#{method_name.to_s}' specified.")
      end

      if method_name.to_s =~ /=\z/
        if field.composite
          self.values[field.composite_sequence] ||= {}
          self.values[field.composite_sequence][field.sequence] = args[0]
        else
          self.values[field.sequence] = args[0]
        end
      else
        if field.composite
          self.values[field.composite_sequence][field.sequence]
        else
          self.values[field.sequence]
        end
      end
    end
  end
end
