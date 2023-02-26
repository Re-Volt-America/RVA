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
            key, index = $1, $2.to_i
            (multi_parameter_attributes[key] ||= {})[index] = value.empty? ? nil : value.send("to_#{$3}")
          else
            attributes[key] = value
          end
        end

        multi_parameter_attributes.each_pair do |key, values|
          begin
            values = (values.keys.min..values.keys.max).map { |i| values[i] }
            field = self.class.fields[database_field_name(key)]
            attributes[key] = instantiate_object(field, values)
          rescue => e
            errors << Errors::AttributeAssignmentError.new(
                "error on assignment #{values.inspect} to #{key}", e, key
            )
          end
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
      return nil if values_with_empty_parameters.all? { |v| v.nil? }
      values = values_with_empty_parameters.collect { |v| v.nil? ? 1 : v }
      klass = field.type
      if klass == DateTime || klass == Date || klass == Time
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

