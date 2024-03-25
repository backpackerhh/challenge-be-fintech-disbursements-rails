# frozen_string_literal: true

class AddStartDateAndEndDateIndexToPaymentsDisbursements < ActiveRecord::Migration[7.1]
  def change
    add_index :payments_disbursements, %i[start_date end_date]
  end
end
