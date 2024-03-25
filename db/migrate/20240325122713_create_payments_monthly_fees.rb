# frozen_string_literal: true

class CreatePaymentsMonthlyFees < ActiveRecord::Migration[7.1]
  def change
    create_table :payments_monthly_fees, id: :uuid, default: nil do |t|
      t.monetize :amount, amount: { null: false }, currency: { present: false }
      t.monetize :commissions_amount, amount: { null: false }, currency: { present: false }
      t.references :payments_merchant, foreign_key: true, type: :uuid, null: false
      t.string :month, null: false, limit: 7
      t.timestamps
    end
  end
end
