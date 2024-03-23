# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Entities
      class OrderCommissionEntity < SharedContext::Entities::AggregateRoot
        attr_reader :id, :order_id, :order_amount, :fee, :amount

        def self.from_primitives(attributes)
          new(id: attributes.fetch(:id, SecureRandom.uuid),
              order_id: attributes.fetch(:order_id),
              order_amount: attributes.fetch(:order_amount),
              fee: attributes.fetch(:fee, nil),
              amount: attributes.fetch(:amount, nil))
        end

        def initialize(id:, order_id:, order_amount:, fee:, amount:)
          super()
          @id = ValueObjects::OrderCommissionIdValueObject.new(value: id)
          @order_id = ValueObjects::OrderCommissionOrderIdValueObject.new(value: order_id)
          @order_amount = ValueObjects::OrderCommissionOrderAmountValueObject.new(value: order_amount)
          @fee = ValueObjects::OrderCommissionFeeValueObject.new(value: fee || select_fee)
          @amount = ValueObjects::OrderCommissionAmountValueObject.new(value: amount || calculate_amount)
        end

        def to_primitives
          {
            id: id.value,
            order_id: order_id.value,
            order_amount: order_amount.value.amount,
            fee: fee.value,
            amount: amount.value.amount
          }
        end

        private

        def select_fee(domain_service = Services::SelectApplicableFeeService.new)
          domain_service.select_fee(order_amount.value.amount)
        end

        def calculate_amount(domain_service = Services::CalculateCommissionAmountService.new)
          domain_service.calculate(order_amount.value, fee.value)
        end
      end
    end
  end
end
