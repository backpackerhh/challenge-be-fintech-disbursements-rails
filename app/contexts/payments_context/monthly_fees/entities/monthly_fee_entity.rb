# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Entities
      class MonthlyFeeEntity < SharedContext::Entities::AggregateRoot
        attr_reader :id, :merchant_id, :amount, :commissions_amount, :month

        def self.from_primitives(attributes)
          new(id: attributes.fetch(:id, SecureRandom.uuid),
              merchant_id: attributes.fetch(:merchant_id),
              amount: attributes.fetch(:amount),
              commissions_amount: attributes.fetch(:commissions_amount),
              month: attributes.fetch(:month))
        end

        def initialize(id:, merchant_id:, amount:, commissions_amount:, month:)
          super()
          @id = ValueObjects::MonthlyFeeIdValueObject.new(value: id)
          @merchant_id = ValueObjects::MonthlyFeeMerchantIdValueObject.new(value: merchant_id)
          @amount = ValueObjects::MonthlyFeeAmountValueObject.new(value: amount)
          @commissions_amount = ValueObjects::MonthlyFeeCommissionsAmountValueObject.new(value: commissions_amount)
          @month = ValueObjects::MonthlyFeeMonthValueObject.new(value: month)
        end

        def to_primitives
          {
            id: id.value,
            merchant_id: merchant_id.value,
            amount: amount.value.amount,
            commissions_amount: commissions_amount.value.amount,
            month: month.value
          }
        end
      end
    end
  end
end
