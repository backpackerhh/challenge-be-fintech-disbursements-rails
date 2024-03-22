# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantDisbursementFrequencyValueObjectFactory
        def self.build(value = ValueObjects::MerchantDisbursementFrequencyValueObject::ALLOWED_VALUES.sample)
          value
        end

        def self.daily
          ValueObjects::MerchantDisbursementFrequencyValueObject::DAILY
        end

        def self.weekly
          ValueObjects::MerchantDisbursementFrequencyValueObject::WEEKLY
        end
      end
    end
  end
end
