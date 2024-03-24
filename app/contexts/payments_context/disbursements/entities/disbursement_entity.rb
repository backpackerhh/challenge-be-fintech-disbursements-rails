# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Entities
      class DisbursementEntity < SharedContext::Entities::AggregateRoot
        attr_reader :id,
                    :merchant_id,
                    :order_ids,
                    :reference,
                    :amount,
                    :commissions_amount,
                    :start_date,
                    :end_date

        def self.from_primitives(attributes)
          new(id: attributes.fetch(:id, SecureRandom.uuid),
              merchant_id: attributes.fetch(:merchant_id),
              order_ids: attributes.fetch(:order_ids),
              reference: attributes.fetch(:reference, SecureRandom.alphanumeric(12)),
              amount: attributes.fetch(:amount),
              commissions_amount: attributes.fetch(:commissions_amount),
              start_date: attributes.fetch(:start_date),
              end_date: attributes.fetch(:end_date))
        end

        def initialize(
          id:,
          merchant_id:,
          order_ids:,
          reference:,
          amount:,
          commissions_amount:,
          start_date:,
          end_date:
        )
          super()
          @id = ValueObjects::DisbursementIdValueObject.new(value: id)
          @merchant_id = ValueObjects::DisbursementMerchantIdValueObject.new(value: merchant_id)
          @order_ids = ValueObjects::DisbursementOrderIdsValueObject.new(value: order_ids)
          @reference = ValueObjects::DisbursementReferenceValueObject.new(value: reference)
          @amount = ValueObjects::DisbursementAmountValueObject.new(value: amount)
          @commissions_amount = ValueObjects::DisbursementCommissionsAmountValueObject.new(value: commissions_amount)
          @start_date = ValueObjects::DisbursementStartDateValueObject.new(value: start_date)
          @end_date = ValueObjects::DisbursementEndDateValueObject.new(value: end_date)
        end

        def to_primitives
          {
            id: id.value,
            merchant_id: merchant_id.value,
            order_ids: order_ids.value,
            reference: reference.value,
            amount: amount.value.amount,
            commissions_amount: commissions_amount.value.amount,
            start_date: start_date.value,
            end_date: end_date.value
          }
        end
      end
    end
  end
end
