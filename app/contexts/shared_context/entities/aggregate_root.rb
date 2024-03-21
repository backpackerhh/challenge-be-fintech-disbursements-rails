# frozen_string_literal: true

module SharedContext
  module Entities
    class AggregateRoot
      private_class_method :new

      def to_primitives
        raise NotImplementedError, "Define #to_primitives method"
      end

      def ==(other)
        id == other.id && self.class == other.class
      end
    end
  end
end
