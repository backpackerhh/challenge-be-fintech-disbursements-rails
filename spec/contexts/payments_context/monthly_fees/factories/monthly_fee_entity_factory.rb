# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Factories
      class MonthlyFeeEntityFactory
        FactoryBot.define do
          factory :payments_monthly_fee, class: "PaymentsContext::MonthlyFees::Records::MonthlyFeeRecord" do
            id { MonthlyFeeIdValueObjectFactory.build }
            merchant_id { MonthlyFeeMerchantIdValueObjectFactory.build }
            amount { MonthlyFeeAmountValueObjectFactory.build }
            commissions_amount { MonthlyFeeCommissionsAmountValueObjectFactory.build(amount) }
            month { MonthlyFeeMonthValueObjectFactory.build }
          end
        end

        def self.build(...)
          attributes = FactoryBot.attributes_for(:payments_monthly_fee, ...)

          Entities::MonthlyFeeEntity.from_primitives(attributes)
        end

        def self.create(...)
          attributes = FactoryBot.attributes_for(:payments_monthly_fee, ...)

          FactoryBot.create(:payments_monthly_fee, attributes)

          Entities::MonthlyFeeEntity.from_primitives(attributes)
        end
      end
    end
  end
end
