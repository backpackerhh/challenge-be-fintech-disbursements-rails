# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Factories
      class OrderCommissionEntityFactory
        FactoryBot.define do
          factory :payments_order_commission,
                  class: "PaymentsContext::OrderCommissions::Records::OrderCommissionRecord" do
            id { OrderCommissionIdValueObjectFactory.build }
            order_id { OrderCommissionOrderIdValueObjectFactory.build }
            order_amount { OrderCommissionOrderAmountValueObjectFactory.build }
            fee { OrderCommissionFeeValueObjectFactory.build(order_amount) }
            amount { OrderCommissionAmountValueObjectFactory.build(order_amount, fee) }
          end
        end

        def self.build(...)
          attributes = FactoryBot.attributes_for(:payments_order_commission, ...)

          Entities::OrderCommissionEntity.from_primitives(attributes)
        end

        def self.create(...)
          attributes = FactoryBot.attributes_for(:payments_order_commission, ...)

          FactoryBot.create(:payments_order_commission, attributes)

          Entities::OrderCommissionEntity.from_primitives(attributes)
        end
      end
    end
  end
end
