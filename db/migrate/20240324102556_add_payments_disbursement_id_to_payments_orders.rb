# frozen_string_literal: true

class AddPaymentsDisbursementIdToPaymentsOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :payments_orders, :payments_disbursement, foreign_key: true, type: :uuid, null: true
  end
end
