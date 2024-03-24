# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Factories
      class OrderDisbursementIdValueObjectFactory
        def self.build(value = SecureRandom.uuid)
          value
        end
      end
    end
  end
end
