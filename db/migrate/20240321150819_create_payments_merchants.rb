# frozen_string_literal: true

class CreatePaymentsMerchants < ActiveRecord::Migration[7.1]
  def up
    execute "CREATE TYPE payments_merchant_disbursement_frequency_enum AS ENUM ('DAILY', 'WEEKLY')"

    create_table :payments_merchants, id: :uuid, default: nil do |t|
      t.string :email, null: false
      t.string :reference, null: false, index: { unique: true }
      t.enum :disbursement_frequency, enum_type: :payments_merchant_disbursement_frequency_enum, null: false
      t.date :live_on, null: false
      t.decimal :minimum_monthly_fee, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end

  def down
    drop_table :payments_merchants if table_exists?(:payments_merchants)

    execute "DROP TYPE IF EXISTS payments_merchant_disbursement_frequency_enum"
  end
end
