# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Repositories
      class PostgresOrderRepository
        def create(attributes)
          Records::OrderRecord.create!(attributes)
        rescue ActiveRecord::RecordNotUnique => e
          raise SharedContext::Errors::DuplicatedRecordError, e
        rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation => e
          raise SharedContext::Errors::InvalidArgumentError, e
        rescue ActiveRecord::InvalidForeignKey => e
          raise SharedContext::Errors::RecordNotFoundError, e
        end

        def size
          Records::OrderRecord.count
        end
      end
    end
  end
end
