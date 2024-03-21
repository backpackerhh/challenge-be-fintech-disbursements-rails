# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantEntityFactory
        FactoryBot.define do
          factory :payments_merchant, class: "PaymentsContext::Merchants::Records::MerchantRecord" do
            id { MerchantIdFactory.build }
            reference { MerchantReferenceFactory.build }
            email { MerchantEmailFactory.build }
            disbursement_frequency { MerchantDisbursementFrequencyFactory.build }
            live_on { MerchantLiveOnFactory.build }
            minimum_monthly_fee { MerchantMinimumMonthlyFeeFactory.build }
            created_at { MerchantCreatedAtFactory.build }

            trait :weekly_disbursement do |m|
              m.disbursement_frequency { MerchantDisbursementFrequencyFactory.weekly }
            end

            trait :daily_disbursement do |m|
              m.disbursement_frequency { MerchantDisbursementFrequencyFactory.daily }
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
