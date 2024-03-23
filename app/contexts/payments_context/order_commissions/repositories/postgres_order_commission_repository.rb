# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Repositories
      class PostgresOrderCommissionRepository
        def create(attributes)
          Records::OrderCommissionRecord.create!(attributes)
        rescue ActiveRecord::RecordNotUnique => e
          raise SharedContext::Errors::DuplicatedRecordError, e
        rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation => e
          raise SharedContext::Errors::InvalidArgumentError, e
        rescue ActiveRecord::InvalidForeignKey => e
          raise SharedContext::Errors::RecordNotFoundError, e
        end

        def size
          Records::OrderCommissionRecord.count
        end
      end
    end
  end
end
