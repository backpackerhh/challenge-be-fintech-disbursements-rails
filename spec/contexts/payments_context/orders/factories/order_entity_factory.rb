# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Factories
      class OrderEntityFactory
        FactoryBot.define do
          factory :payments_order, class: "PaymentsContext::Orders::Records::OrderRecord" do
            id { OrderIdValueObjectFactory.build }
            merchant_id { OrderMerchantIdValueObjectFactory.build }
            disbursement_id { nil }
            reference { OrderReferenceValueObjectFactory.build }
            amount { OrderAmountValueObjectFactory.build }
            created_at { OrderCreatedAtValueObjectFactory.build }
          end
        end

        def self.build(...)
          attributes = FactoryBot.attributes_for(:payments_order, ...)

          Entities::OrderEntity.from_primitives(attributes)
        end

        def self.create(...)
          attributes = FactoryBot.attributes_for(:payments_order, ...)

          FactoryBot.create(:payments_order, attributes)

          Entities::OrderEntity.from_primitives(attributes)
        end
      end
    end
  end
end
