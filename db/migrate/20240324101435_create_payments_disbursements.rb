# frozen_string_literal: true

class CreatePaymentsDisbursements < ActiveRecord::Migration[7.1]
  def change
    create_table :payments_disbursements, id: :uuid, default: nil do |t|
      t.string :reference, null: false, index: { unique: true }
      t.monetize :amount, amount: { null: false }, currency: { present: false }
      t.monetize :commissions_amount, amount: { null: false }, currency: { present: false }
      t.references :payments_merchant, foreign_key: true, type: :uuid, null: false
      t.uuid :order_ids, array: true, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.timestamps
    end
  end
end
