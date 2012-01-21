require 'date'
require 'time'
require 'bigdecimal'

module Hippo
  class Field
    attr_accessor :name, :sequence, :datatype, :options,
                  :restrictions, :minimum, :maximum, :required,
                  :separator, :composite, :composite_sequence

    def minimum
      @minimum ||= 0
    end

    def formatted_value(value)
      return nil if value.nil?

      case datatype
      when :binary  then value
      when :integer then value.to_i
      when :decimal then BigDecimal.new(value.to_s)
      when :date    then parse_date(value)
      when :time    then parse_time(value)
      else value.to_s.strip
      end
    end

    def string_value(value)
      return '' if value.nil? && !required

      case datatype
      when :binary  then value
      when :integer then value.to_s.rjust(minimum, '0')
      when :decimal then
        value ||= BigDecimal.new('0')

        value.to_s('F').sub(/\.0\z/,'').rjust(minimum, '0')
      when :date
        value ||= Date.today

        if maximum == 6
          value.strftime('%y%m%d')
        else
          value.strftime('%Y%m%d')
        end
      when :time
        value ||= Time.now

        if maximum == 4 || value.sec == 0
          value.strftime('%H%M')
        else
          value.strftime('%H%M%S')
        end
      else value.to_s.ljust(minimum)
      end
    end

    def parse_time(value)
      case value.class.to_s
      when 'Time' then value
      when 'String'
        format =  case value
                  when /\A\d{4}\z/ then '%H%M'
                  when /\A\d{6}\z/ then '%H%M%S'
                  when /\A\d{7,8}\z/ then '%H%M%S%N'
                  else invalid!
                  end

        Time.strptime(value, format)
      else invalid!
      end
    rescue
      invalid!
    end

    def parse_date(value)
      case value.class.to_s
      when "Date" then value
      when "Time" then value.to_date
      when "String"
        format =  case value
                  when /\A\d{6}\z/ then '%y%m%d'
                  when /\A\d{8}\z/ then '%Y%m%d'
                  else invalid!
                  end

        Date.parse(value, format)
      else
        invalid! "Invalid datatype(#{value.class}) for date field."
      end
    rescue
      invalid!
    end

    def invalid!(message = "Invalid value specified for #{self.datatype} field.")
      raise Hippo::Exceptions::InvalidValue.new message
    end
  end
end
