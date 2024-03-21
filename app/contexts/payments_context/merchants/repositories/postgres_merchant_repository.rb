# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Repositories
      class PostgresMerchantRepository
        def create(attributes)
          Records::MerchantRecord.create!(attributes)
        rescue ActiveRecord::RecordNotUnique => e
          raise SharedContext::Errors::DuplicatedRecordError, e
        rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation => e
          raise SharedContext::Errors::InvalidArgumentError, e
        end

        def size
          Records::MerchantRecord.count
        end
      end
    end
  end
end
