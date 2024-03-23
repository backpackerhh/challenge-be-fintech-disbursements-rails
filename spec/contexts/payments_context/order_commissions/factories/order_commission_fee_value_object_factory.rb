# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Factories
      class OrderCommissionFeeValueObjectFactory
        def self.build(order_amount)
          Services::SelectApplicableFeeService.new.select_fee(order_amount.amount)
        end
      end
    end
  end
end
