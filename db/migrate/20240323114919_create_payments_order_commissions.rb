# frozen_string_literal: true

class CreatePaymentsOrderCommissions < ActiveRecord::Migration[7.1]
  def change
    create_table :payments_order_commissions, id: :uuid, default: nil do |t|
      t.monetize :amount, amount: { null: false }, currency: { present: false }
      t.monetize :order_amount, amount: { null: false }, currency: { present: false }
      t.references :payments_order, foreign_key: true, type: :uuid, null: false, index: { unique: true }
      t.decimal :fee, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
