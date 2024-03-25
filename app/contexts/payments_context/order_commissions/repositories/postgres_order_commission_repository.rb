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

        def calculate_monthly_amount(merchant_id, date)
          monthly_amount = Records::OrderCommissionRecord.connection.select_value(
            <<~SQL.squish
              SELECT SUM(oc.amount_cents) / 100.0 AS monthly_amount
              FROM payments_order_commissions oc
              JOIN payments_orders o
              ON o.id = oc.payments_order_id
              WHERE o.payments_merchant_id = '#{merchant_id}'
              AND DATE(o.created_at) >= DATE_TRUNC('month', DATE('#{date}'))
              AND DATE(o.created_at) < (DATE_TRUNC('month', DATE('#{date}')) + INTERVAL '1 month')
            SQL
          )

          monthly_amount || 0.0
        end
      end
    end
  end
end
