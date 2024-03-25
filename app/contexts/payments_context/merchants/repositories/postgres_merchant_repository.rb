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

        def find_by_id(id)
          merchant = Records::MerchantRecord.find(id)

          Entities::MerchantEntity.from_primitives(merchant.attributes.transform_keys(&:to_sym))
        rescue ActiveRecord::RecordNotFound => e
          raise SharedContext::Errors::RecordNotFoundError, e
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

        def find_all_grouped_disbursable_ids
          grouped_merchant_ids = Records::MerchantRecord.connection.execute(
            <<~SQL.squish
              SELECT JSON_AGG(id) AS merchant_ids, disbursement_frequency
                FROM payments_merchants
                WHERE disbursement_frequency = '#{ValueObjects::MerchantDisbursementFrequencyValueObject::DAILY}'
                OR (
                  disbursement_frequency = '#{ValueObjects::MerchantDisbursementFrequencyValueObject::WEEKLY}' AND
                  DATE_PART('isodow', live_on) = DATE_PART('isodow', DATE('#{Date.current}'))
                )
                GROUP BY disbursement_frequency
            SQL
          )

          grouped_merchant_ids.to_a.each_with_object({}) do |row, memo|
            memo[row["disbursement_frequency"]] = JSON.parse(row["merchant_ids"])
          end
        end
      end
    end
  end
end
