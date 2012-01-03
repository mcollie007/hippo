module Hippo
  module Separator
    attr_accessor :field_separator, :composite_separator, :repetition_separator, :segment_separator

    def initialize(options = {})
      [:field_separator, :repetition_separator, :composite_separator, :segment_separator].each do |sym|
        value = options[sym] || parent_or_default_separator(sym)

        self.send(:"#{sym}=", value)
      end
    end

    def parent_or_default_separator(separator_type)
      if defined?(parent) && parent
        parent.send(separator_type.to_sym)
      else
        Hippo.const_get(:"DEFAULT_#{separator_type.to_s.upcase}")
      end
    end

    def parse_separators(input)
      if input =~ /\AISA/
        @field_separator      = input[3]
        @repetition_separator = input[82]
        @composite_separator  = input[104]
        @segment_separator    = input[105]
      end
    end

    def separators
      {
        :field_separator      => @field_separator,
        :composite_separator  => @composite_separator,
        :segment_separator    => @segment_separator,
        :repetition_separator => @repetition_separator
      }
    end
  end
end