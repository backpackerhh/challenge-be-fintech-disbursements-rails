# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Factories
      class DisbursementEntityFactory
        FactoryBot.define do
          factory :payments_disbursement, class: "PaymentsContext::Disbursements::Records::DisbursementRecord" do
            id { DisbursementIdValueObjectFactory.build }
            merchant_id { DisbursementMerchantIdValueObjectFactory.build }
            order_ids { DisbursementOrderIdsValueObjectFactory.build }
            reference { DisbursementReferenceValueObjectFactory.build }
            amount { DisbursementAmountValueObjectFactory.build }
            commissions_amount { DisbursementCommissionsAmountValueObjectFactory.build(amount) }
            start_date { DisbursementStartDateValueObjectFactory.build }
            end_date { DisbursementEndDateValueObjectFactory.build }
          end
        end

        def self.build(...)
          attributes = FactoryBot.attributes_for(:payments_disbursement, ...)

          Entities::DisbursementEntity.from_primitives(attributes)
        end

        def self.create(...)
          attributes = FactoryBot.attributes_for(:payments_disbursement, ...)

          FactoryBot.create(:payments_disbursement, attributes)

          Entities::DisbursementEntity.from_primitives(attributes)
        end
      end
    end
  end
end
