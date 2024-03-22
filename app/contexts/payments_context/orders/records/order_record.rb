# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Records
      class OrderRecord < SharedContext::Records::ApplicationRecord
        self.table_name = "payments_orders"

        monetize :amount_cents, disable_validation: true

        alias_attribute :merchant_id, :payments_merchant_id
      end
    end
  end
end
