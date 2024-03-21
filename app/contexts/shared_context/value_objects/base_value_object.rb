# frozen_string_literal: true

require "dry-struct"
require "dry-types"

module SharedContext
  module ValueObjects
    class BaseValueObject < Dry::Struct
      Types = Dry.Types()

      transform_keys(&:to_sym)

      # @see https://github.com/dry-rb/dry-struct/blob/release-1.6/lib/dry/struct/class_interface.rb#L249
      def self.new(*)
        super
      rescue Dry::Struct::Error => e
        raise Errors::InvalidArgumentError, e
      end

      def self.value_type(type)
        attribute :value, type
      end

      def initialize(*)
        super

        if !respond_to?(:value)
          raise Errors::NotImplementedError, "Define the type for the value object with .value_type class method"
        end
      end

      def ==(other)
        value == other.value
      end
    end
  end
end
