# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module ValueObjects
      class MerchantDisbursementFrequencyValueObject < SharedContext::ValueObjects::EnumValueObject
        DAILY = "DAILY"
        WEEKLY = "WEEKLY"

        allowed_values [DAILY, WEEKLY]
      end
    end
  end
end
