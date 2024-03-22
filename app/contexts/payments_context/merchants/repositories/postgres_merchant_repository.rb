# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Repositories
      class PostgresMerchantRepository
        def all
          merchants = Records::MerchantRecord.all

          merchants.map do |merchant|
            Entities::MerchantEntity.from_primitives(merchant.attributes.transform_keys(&:to_sym))
          end
        end

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
