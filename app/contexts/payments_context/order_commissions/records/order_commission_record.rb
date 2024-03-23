# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Records
      class OrderCommissionRecord < SharedContext::Records::ApplicationRecord
        self.table_name = "payments_order_commissions"

        monetize :amount_cents, disable_validation: true
        monetize :order_amount_cents, disable_validation: true

        alias_attribute :order_id, :payments_order_id
      end
    end
  end
end
