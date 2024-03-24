# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Records
      class DisbursementRecord < SharedContext::Records::ApplicationRecord
        self.table_name = "payments_disbursements"

        monetize :amount_cents, disable_validation: true
        monetize :commissions_amount_cents, disable_validation: true

        alias_attribute :merchant_id, :payments_merchant_id
      end
    end
  end
end
