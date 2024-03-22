# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Entities
      class OrderEntity < SharedContext::Entities::AggregateRoot
        attr_reader :id, :merchant_id, :reference, :amount, :created_at

        def self.from_primitives(attributes)
          new(id: attributes.fetch(:id),
              merchant_id: attributes.fetch(:merchant_id),
              reference: attributes.fetch(:reference),
              amount: attributes.fetch(:amount),
              created_at: attributes.fetch(:created_at))
        end

        def initialize(id:, merchant_id:, reference:, amount:, created_at:)
          super()
          @id = ValueObjects::OrderIdValueObject.new(value: id)
          @merchant_id = ValueObjects::OrderMerchantIdValueObject.new(value: merchant_id)
          @reference = ValueObjects::OrderReferenceValueObject.new(value: reference)
          @amount = ValueObjects::OrderAmountValueObject.new(value: amount)
          @created_at = ValueObjects::OrderCreatedAtValueObject.new(value: created_at)
        end

        def to_primitives
          {
            id: id.value,
            merchant_id: merchant_id.value,
            reference: reference.value,
            amount: amount.value.amount,
            created_at: created_at.value
          }
        end
      end
    end
  end
end
