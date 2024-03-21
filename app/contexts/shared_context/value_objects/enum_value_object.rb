# frozen_string_literal: true

module SharedContext
  module ValueObjects
    class EnumValueObject < BaseValueObject
      def self.allowed_values(values)
        const_set(:ALLOWED_VALUES, values.freeze)

        value_type Types::Strict::String.enum(*const_get(:ALLOWED_VALUES))
      end

      def initialize(*)
        if !self.class.const_defined?(:ALLOWED_VALUES)
          raise NotImplementedError, "Define allowed values for the enum type with .allowed_values class method"
        end

        super
      end
    end
  end
end
