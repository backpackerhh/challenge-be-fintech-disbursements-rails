# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Records
      class MerchantRecord < SharedContext::Records::ApplicationRecord
        self.table_name = "payments_merchants"
      end
    end
  end
end
