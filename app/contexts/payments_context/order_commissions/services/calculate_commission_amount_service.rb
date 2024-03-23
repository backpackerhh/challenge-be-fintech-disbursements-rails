# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Services
      class CalculateCommissionAmountService
        def calculate(order_amount, fee)
          (order_amount * fee / 100).amount
        end
      end
    end
  end
end
