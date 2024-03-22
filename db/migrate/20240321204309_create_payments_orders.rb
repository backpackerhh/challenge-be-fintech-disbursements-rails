# frozen_string_literal: true

class CreatePaymentsOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :payments_orders, id: :uuid, default: nil do |t|
      t.string :reference, null: false, index: { unique: true }
      t.monetize :amount, amount: { null: false }, currency: { present: false }
      t.references :payments_merchant, foreign_key: true, type: :uuid, null: false
      t.timestamps
    end
  end
end
