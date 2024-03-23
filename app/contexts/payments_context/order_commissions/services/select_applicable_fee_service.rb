# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Services
      class SelectApplicableFeeService
        FEE_TIERS = {
          0.0...50.0 => BigDecimal("1.0"),
          50.0...300.0 => BigDecimal("0.95"),
          300.0... => BigDecimal("0.85")
        }.freeze

        def select_fee(order_amount)
          FEE_TIERS.detect { |fee_tier, _fee| fee_tier.include?(order_amount) }.last
        end
      end
    end
  end
end
