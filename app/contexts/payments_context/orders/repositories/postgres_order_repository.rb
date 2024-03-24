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

        def group_all_disbursable(grouping_type, merchant_id)
          case grouping_type.downcase
          when "daily"
            Records::OrderRecord.connection.execute(
              <<~SQL.squish
                SELECT
                  DATE(o.created_at) AS start_date,
                  DATE(o.created_at) AS end_date,
                  JSON_AGG(o.id) AS order_ids,
                  SUM(o.amount_cents) / 100.0 AS amount,
                  SUM(oc.amount_cents) / 100.0 as commissions_amount
                FROM payments_orders o
                JOIN payments_order_commissions oc
                ON o.id = oc.payments_order_id
                WHERE o.payments_merchant_id = '#{merchant_id}'
                AND o.payments_disbursement_id IS NULL
                AND DATE(o.created_at) < DATE('#{Date.current}')
                GROUP BY DATE(o.created_at)
                ORDER BY start_date ASC;
              SQL
            ).to_a
          when "weekly"
            Records::OrderRecord.connection.execute(
              <<~SQL.squish
                SELECT
                  DATE(DATE_TRUNC('week', o.created_at)) AS start_date,
                  DATE(DATE_TRUNC('week', o.created_at) + INTERVAL '6 days') AS end_date,
                  JSON_AGG(o.id) AS order_ids,
                  SUM(o.amount_cents) / 100.0 AS amount,
                  SUM(oc.amount_cents) / 100.0 as commissions_amount
                FROM payments_orders o
                JOIN payments_order_commissions oc
                ON o.id = oc.payments_order_id
                WHERE o.payments_merchant_id = '#{merchant_id}'
                AND o.payments_disbursement_id IS NULL
                AND DATE_TRUNC('week', o.created_at) < DATE_TRUNC('week', DATE('#{Date.current}'))
                GROUP BY DATE_TRUNC('week', o.created_at)
                ORDER BY start_date ASC;
              SQL
            ).to_a
          else
            raise Errors::UnsupportedGroupingTypeError, "Supported grouping types: daily, weekly"
          end
        end
      end
    end
  end
end
