# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Entities
      class MerchantEntity < SharedContext::Entities::AggregateRoot
        attr_reader :id, :email, :reference, :disbursement_frequency, :live_on, :minimum_monthly_fee, :created_at

        def self.from_primitives(attributes)
          new(id: attributes.fetch(:id),
              email: attributes.fetch(:email),
              reference: attributes.fetch(:reference),
              disbursement_frequency: attributes.fetch(:disbursement_frequency),
              live_on: attributes.fetch(:live_on),
              minimum_monthly_fee: attributes.fetch(:minimum_monthly_fee),
              created_at: attributes.fetch(:created_at, Time.current))
        end

        def initialize(id:, email:, reference:, disbursement_frequency:, live_on:, minimum_monthly_fee:, created_at:)
          super()
          @id = ValueObjects::MerchantIdValueObject.new(value: id)
          @email = ValueObjects::MerchantEmailValueObject.new(value: email)
          @reference = ValueObjects::MerchantReferenceValueObject.new(value: reference)
          @disbursement_frequency =
            ValueObjects::MerchantDisbursementFrequencyValueObject.new(value: disbursement_frequency)
          @live_on = ValueObjects::MerchantLiveOnValueObject.new(value: live_on)
          @minimum_monthly_fee = ValueObjects::MerchantMinimumMonthlyFeeValueObject.new(value: minimum_monthly_fee)
          @created_at = ValueObjects::MerchantCreatedAtValueObject.new(value: created_at)
        end

        def to_primitives
          {
            id: id.value,
            email: email.value,
            reference: reference.value,
            disbursement_frequency: disbursement_frequency.value,
            live_on: live_on.value,
            minimum_monthly_fee: minimum_monthly_fee.value,
            created_at: created_at.value
          }
        end

        def monthly_fee_applicable?(commissions_amount, previous_month_date)
          !minimum_monthly_fee.value.zero? &&
            minimum_monthly_fee.value > commissions_amount &&
            (live_on.value.year < previous_month_date.year ||
            (live_on.value.year == previous_month_date.year && live_on.value.month <= previous_month_date.month))
        end
      end
    end
  end
end
