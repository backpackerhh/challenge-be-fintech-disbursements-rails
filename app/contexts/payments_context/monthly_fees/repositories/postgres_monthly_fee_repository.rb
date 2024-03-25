# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Repositories
      class PostgresMonthlyFeeRepository
        def all
          monthly_fees = Records::MonthlyFeeRecord.all

          monthly_fees.map do |monthly_fee|
            Entities::MonthlyFeeEntity.from_primitives(
              id: monthly_fee.id,
              merchant_id: monthly_fee.merchant_id,
              amount: monthly_fee.amount,
              commissions_amount: monthly_fee.commissions_amount,
              month: monthly_fee.month
            )
          end
        end

        def create(attributes)
          Records::MonthlyFeeRecord.create!(attributes)
        rescue ActiveRecord::RecordNotUnique => e
          raise SharedContext::Errors::DuplicatedRecordError, e
        rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation => e
          raise SharedContext::Errors::InvalidArgumentError, e
        rescue ActiveRecord::InvalidForeignKey => e
          raise SharedContext::Errors::RecordNotFoundError, e
        end

        def size
          Records::MonthlyFeeRecord.count
        end
      end
    end
  end
end
