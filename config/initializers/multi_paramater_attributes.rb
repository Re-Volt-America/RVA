module Mongoid
  module MultiParameterAttributes
    module Errors
      class AttributeAssignmentError < Mongoid::Errors::MongoidError
        attr_reader :exception, :attribute

        def initialize(message, exception, attribute)
          @exception = exception
          @attribute = attribute
          @message = message
        end
      end

      class MultiparameterAssignmentErrors < Mongoid::Errors::MongoidError
        attr_reader :errors

        def initialize(errors)
          @errors = errors
        end
      end
    end

    def process_attributes(attrs = nil)
      if attrs
        errors = []
        attributes = attrs.class.new
        attributes.permit! if attrs.respond_to?(:permitted?) && attrs.permitted?
        multi_parameter_attributes = {}
        attrs.each_pair do |key, value|
          if key =~ /\A([^\(]+)\((\d+)([if])\)$/
            key = ::Regexp.last_match(1)
            index = ::Regexp.last_match(2).to_i
            (multi_parameter_attributes[key] ||= {})[index] =
              value.empty? ? nil : value.send("to_#{::Regexp.last_match(3)}")
          else
            attributes[key] = value
          end
        end

        multi_parameter_attributes.each_pair do |key, values|
          values = (values.keys.min..values.keys.max).map { |i| values[i] }
          field = self.class.fields[database_field_name(key)]
          attributes[key] = instantiate_object(field, values)
        rescue StandardError => e
          errors << Errors::AttributeAssignmentError.new(
            "error on assignment #{values.inspect} to #{key}", e, key
          )
        end

        unless errors.empty?
          raise Errors::MultiparameterAssignmentErrors.new(errors),
                "#{errors.size} error(s) on assignment of multiparameter attributes"
        end

        super attributes
      else
        super
      end
    end

    protected

    def instantiate_object(field, values_with_empty_parameters)
      return nil if values_with_empty_parameters.all?(&:nil?)

      values = values_with_empty_parameters.collect { |v| v.nil? ? 1 : v }
      klass = field.type
      if [DateTime, Date, Time].include?(klass)
        field.mongoize(values)
      elsif klass
        klass.new(*values)
      else
        values
      end
    end
  end

  module Document
    include MultiParameterAttributes
  end
end
