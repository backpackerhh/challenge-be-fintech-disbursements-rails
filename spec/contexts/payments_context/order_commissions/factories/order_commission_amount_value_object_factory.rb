# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Factories
      class OrderCommissionAmountValueObjectFactory
        def self.build(order_amount, fee)
          Services::CalculateCommissionAmountService.new.calculate(order_amount, fee)
        end
      end
    end
  end
end
