# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantEntityFactory
        FactoryBot.define do
          factory :payments_merchant, class: "PaymentsContext::Merchants::Records::MerchantRecord" do
            id { MerchantIdValueObjectFactory.build }
            reference { MerchantReferenceValueObjectFactory.build }
            email { MerchantEmailValueObjectFactory.build }
            disbursement_frequency { MerchantDisbursementFrequencyValueObjectFactory.build }
            live_on { MerchantLiveOnValueObjectFactory.build }
            minimum_monthly_fee { MerchantMinimumMonthlyFeeValueObjectFactory.build }
            created_at { MerchantCreatedAtValueObjectFactory.build }

            trait :weekly_disbursement do |m|
              m.disbursement_frequency { MerchantDisbursementFrequencyValueObjectFactory.weekly }
            end

            trait :daily_disbursement do |m|
              m.disbursement_frequency { MerchantDisbursementFrequencyValueObjectFactory.daily }
            end
          end
        end

        def self.build(...)
          attributes = FactoryBot.attributes_for(:payments_merchant, ...)

          Entities::MerchantEntity.from_primitives(attributes)
        end

        def self.create(...)
          attributes = FactoryBot.attributes_for(:payments_merchant, ...)

          FactoryBot.create(:payments_merchant, attributes)

          Entities::MerchantEntity.from_primitives(attributes)
        end
      end
    end
  end
end
