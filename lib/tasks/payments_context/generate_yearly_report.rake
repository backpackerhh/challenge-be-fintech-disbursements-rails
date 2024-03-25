# frozen_string_literal: true

namespace :payments_context do
  desc "Generate report with yearly stats in Markdown"
  task generate_yearly_report: :environment do
    data = ActiveRecord::Base.connection.execute(
      <<~SQL.squish
        SELECT CAST(COALESCE(d.year, mf.year, oc.year) AS INTEGER) AS year,
               COALESCE(total_disbursements, 0) AS total_disbursements,
               TO_CHAR(COALESCE(total_disbursements_amount, 0), 'FM999G999G999G999D99') || ' €' AS total_disbursements_amount,
               TO_CHAR(COALESCE(total_order_commissions_amount, 0), 'FM999G999G999G999D99') || ' €' AS total_order_commissions_amount,
               COALESCE(total_monthly_fees, 0) AS total_monthly_fees,
               TO_CHAR(COALESCE(total_monthly_fees_amount, 0), 'FM999G999G999G999D99') || ' €' AS total_monthly_fees_amount
        FROM (
          SELECT EXTRACT(YEAR FROM d.start_date) AS year,
                 COUNT(d.id) AS total_disbursements,
                 SUM(d.amount_cents) / 100.0 AS total_disbursements_amount
          FROM payments_disbursements d
          GROUP BY year
        ) d
        FULL JOIN (
          SELECT EXTRACT(YEAR FROM DATE(mf.month || '-01')) AS year,
                 COUNT(mf.id) AS total_monthly_fees,
                 SUM(mf.amount_cents) / 100.0 AS total_monthly_fees_amount
          FROM payments_monthly_fees mf
          GROUP BY year
        ) mf ON d.year = mf.year
        FULL JOIN (
          SELECT EXTRACT(YEAR FROM o.created_at) AS year,
                 SUM(oc.amount_cents) / 100.0 AS total_order_commissions_amount
          FROM payments_order_commissions oc
          JOIN payments_orders o ON o.id = oc.payments_order_id
          GROUP BY year
        ) oc ON COALESCE(d.year, mf.year) = oc.year
        ORDER BY year
      SQL
    ).to_a
    headers_mapping = {
      year: "Year",
      total_disbursements: "Number of disbursements",
      total_disbursements_amount: "Amount disbursed to merchants",
      total_order_commissions_amount: "Amount of order fees",
      total_monthly_fees: "Number of monthly fees charged (From minimum monthly fee)",
      total_monthly_fees_amount: "Amount of monthly fee charged (From minimum monthly fee)"
    }

    puts "| #{headers_mapping.values.join(' | ')} |"
    puts "|#{':---:|' * headers_mapping.length}"

    data.each do |row|
      puts "| #{headers_mapping.keys.map { |key| row[key.to_s] }.join(' | ')} |"
    end
  rescue StandardError => e
    Rails.logger.error("Generation of report with yearly stats failed: #{e.inspect}")

    puts e.inspect
    puts "Example usage: rake fintech:generate_yearly_report"
  end
end
