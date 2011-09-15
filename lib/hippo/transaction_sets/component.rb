module Hippo::TransactionSets
  class Component
    attr_reader :options, :klass, :sequence, :maximum, :identified_by

    def initialize(options)
      @identified_by  = options.delete(:identified_by)  || {}
      @maximum        = options.delete(:maximum)        || 1
      @klass          = options.delete(:klass)
      @sequence       = options.delete(:sequence)

      @options        = options
    end

    def identifier
      @klass.identifier
    end

    def repeating?
      @maximum > 1
    end

    def populate_component(component, defaults = nil)
      defaults ||= identified_by

      defaults.each do |key, value|
        if key =~ /(\w+)\.(.+)/
          next_component, next_component_value = component.send($1.to_sym), {$2 => value}

          populate_component(next_component, next_component_value)
        else
          component.send((key + '=').to_sym, value)
        end
      end

      component
    end

    def initialize_component(parent)
      if repeating?
        RepeatingComponent.new(self, parent)
      else
        populate_component(@klass.new(:parent => parent))
      end
    end
  end
end
