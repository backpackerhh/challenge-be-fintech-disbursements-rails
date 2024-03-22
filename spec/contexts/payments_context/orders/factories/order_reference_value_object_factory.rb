# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Factories
      class OrderReferenceValueObjectFactory
        def self.build(value = SecureRandom.alphanumeric(12))
          value
        end
      end
    end
  end
end
