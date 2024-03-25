# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Records
      class MonthlyFeeRecord < SharedContext::Records::ApplicationRecord
        self.table_name = "payments_monthly_fees"

        monetize :amount_cents, disable_validation: true
        monetize :commissions_amount_cents, disable_validation: true

        alias_attribute :merchant_id, :payments_merchant_id
      end
    end
  end
end
