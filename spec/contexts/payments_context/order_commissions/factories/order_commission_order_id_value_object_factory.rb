# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Factories
      class OrderCommissionOrderIdValueObjectFactory
        def self.build(value = SecureRandom.uuid)
          value
        end
      end
    end
  end
end
