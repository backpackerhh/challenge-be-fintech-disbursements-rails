# frozen_string_literal: true

class AddCreatedAtIndexToPaymentsOrders < ActiveRecord::Migration[7.1]
  def change
    add_index :payments_orders, :created_at
  end
end
