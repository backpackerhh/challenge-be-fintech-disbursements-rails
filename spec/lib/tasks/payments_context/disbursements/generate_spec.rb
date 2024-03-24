# frozen_string_literal: true

require "rails_helper"

RSpec.describe "payments_context:disbursements:generate", type: %i[task database] do
  include_context "rake"

  it "preloads the environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "starts process to generate disbursements (only daily and weekly on Sundays here)",
     :sidekiq_inline, freeze_time: Time.zone.parse("2023-04-02 07:00 UTC") do
    merchant_a = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
      :weekly_disbursement,
      live_on: Date.parse("2023-01-06"), # Friday
      minimum_monthly_fee: BigDecimal("15.00")
    )
    merchant_b = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
      :daily_disbursement,
      live_on: Date.parse("2023-01-25"), # Wednesday
      minimum_monthly_fee: BigDecimal("30.00")
    )
    merchant_c = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
      :daily_disbursement,
      live_on: Date.parse("2023-02-11"), # Saturday
      minimum_monthly_fee: BigDecimal("0.00")
    )
    merchant_d = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
      :weekly_disbursement,
      live_on: Date.parse("2023-03-05"), # Sunday
      minimum_monthly_fee: BigDecimal("0.00")
    )
    merchant_e = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
      :weekly_disbursement,
      live_on: Date.parse("2023-03-26"), # Sunday
      minimum_monthly_fee: BigDecimal("15.00")
    )

    # Merchant A - Ignored, disbursed weekly on Fridays

    merchant_a_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_a.id.value,
      disbursement_id: nil,
      amount: BigDecimal("158.97"),
      created_at: Time.zone.parse("2023-01-07 14:01:31")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_a_order_1.id.value,
      order_amount: merchant_a_order_1.amount.value,
      amount: BigDecimal("1.52"),
      created_at: Time.zone.parse("2023-01-07 14:01:52")
    )
    merchant_a_order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_a.id.value,
      disbursement_id: nil,
      amount: BigDecimal("26.99"),
      created_at: Time.zone.parse("2023-01-17 07:54:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_a_order_2.id.value,
      order_amount: merchant_a_order_2.amount.value,
      amount: BigDecimal("0.27"),
      created_at: Time.zone.parse("2023-01-17 07:55:13")
    )

    # Merchant B - 3 ready to be disbursed in different days, 1 discarded from today

    merchant_b_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_b.id.value,
      disbursement_id: nil,
      amount: BigDecimal("302.99"),
      created_at: Time.zone.parse("2023-03-31 08:59:31")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_b_order_1.id.value,
      order_amount: merchant_b_order_1.amount.value,
      amount: BigDecimal("2.58"),
      created_at: Time.zone.parse("2023-03-31 08:59:52")
    )
    merchant_b_order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_b.id.value,
      disbursement_id: nil,
      amount: BigDecimal("14.25"),
      created_at: Time.zone.parse("2023-03-31 08:59:45")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_b_order_2.id.value,
      order_amount: merchant_b_order_2.amount.value,
      amount: BigDecimal("0.15"),
      created_at: Time.zone.parse("2023-03-31 09:00:14")
    )
    merchant_b_order_3 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_b.id.value,
      disbursement_id: nil,
      amount: BigDecimal("261.13"),
      created_at: Time.zone.parse("2023-04-01 07:54:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_b_order_3.id.value,
      order_amount: merchant_b_order_3.amount.value,
      amount: BigDecimal("2.49"),
      created_at: Time.zone.parse("2023-04-01 07:55:13")
    )
    merchant_b_order_4 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_b.id.value,
      disbursement_id: nil,
      amount: BigDecimal("1099.99"),
      created_at: Time.zone.parse("2023-04-02 06:54:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_b_order_4.id.value,
      order_amount: merchant_b_order_4.amount.value,
      amount: BigDecimal("9.35"),
      created_at: Time.zone.parse("2023-04-02 06:55:13")
    )

    # Merchant C - 2 orders ready to be disbursed, 2 discarded from today

    merchant_c_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_c.id.value,
      disbursement_id: nil,
      amount: BigDecimal("349.99"),
      created_at: Time.zone.parse("2023-04-01 08:59:31")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_c_order_1.id.value,
      order_amount: merchant_c_order_1.amount.value,
      amount: BigDecimal("2.98"),
      created_at: Time.zone.parse("2023-04-01 08:59:52")
    )
    merchant_c_order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_c.id.value,
      disbursement_id: nil,
      amount: BigDecimal("140.25"),
      created_at: Time.zone.parse("2023-04-01 08:59:45")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_c_order_2.id.value,
      order_amount: merchant_c_order_2.amount.value,
      amount: BigDecimal("1.34"),
      created_at: Time.zone.parse("2023-04-01 09:00:14")
    )
    merchant_c_order_3 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_c.id.value,
      disbursement_id: nil,
      amount: BigDecimal("26.95"),
      created_at: Time.zone.parse("2023-04-02 06:54:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_c_order_3.id.value,
      order_amount: merchant_c_order_3.amount.value,
      amount: BigDecimal("0.27"),
      created_at: Time.zone.parse("2023-04-02 06:55:13")
    )
    merchant_c_order_4 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_c.id.value,
      disbursement_id: nil,
      amount: BigDecimal("10.99"),
      created_at: Time.zone.parse("2023-04-02 06:58:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_c_order_4.id.value,
      order_amount: merchant_c_order_4.amount.value,
      amount: BigDecimal("0.11"),
      created_at: Time.zone.parse("2023-04-02 06:59:13")
    )

    # Merchant D - 4 orders ready to be disbursed in different weeks, 1 discarded from this week

    merchant_d_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_d.id.value,
      disbursement_id: nil,
      amount: BigDecimal("1510.99"),
      created_at: Time.zone.parse("2023-03-16 08:59:31")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_d_order_1.id.value,
      order_amount: merchant_d_order_1.amount.value,
      amount: BigDecimal("12.85"),
      created_at: Time.zone.parse("2023-03-16 08:59:52")
    )
    merchant_d_order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_d.id.value,
      disbursement_id: nil,
      amount: BigDecimal("23.01"),
      created_at: Time.zone.parse("2023-03-16 08:59:45")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_d_order_2.id.value,
      order_amount: merchant_d_order_2.amount.value,
      amount: BigDecimal("0.24"),
      created_at: Time.zone.parse("2023-03-16 09:00:14")
    )
    merchant_d_order_3 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_d.id.value,
      disbursement_id: nil,
      amount: BigDecimal("49.99"),
      created_at: Time.zone.parse("2023-03-18 07:54:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_d_order_3.id.value,
      order_amount: merchant_d_order_3.amount.value,
      amount: BigDecimal("0.5"),
      created_at: Time.zone.parse("2023-03-18 07:55:13")
    )
    merchant_d_order_4 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_d.id.value,
      disbursement_id: nil,
      amount: BigDecimal("50.00"),
      created_at: Time.zone.parse("2023-03-25 06:54:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_d_order_4.id.value,
      order_amount: merchant_d_order_4.amount.value,
      amount: BigDecimal("0.48"),
      created_at: Time.zone.parse("2023-03-25 06:55:13")
    )
    merchant_d_order_5 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_d.id.value,
      disbursement_id: nil,
      amount: BigDecimal("1099.99"),
      created_at: Time.zone.parse("2023-03-31 16:24:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_d_order_5.id.value,
      order_amount: merchant_d_order_5.amount.value,
      amount: BigDecimal("9.35"),
      created_at: Time.zone.parse("2023-03-31 16:24:13")
    )

    # Merchant E - 2 orders ready to be disbursed, 1 discarded from this week

    merchant_e_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_e.id.value,
      disbursement_id: nil,
      amount: BigDecimal("54.99"),
      created_at: Time.zone.parse("2023-03-26 07:54:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_e_order_1.id.value,
      order_amount: merchant_e_order_1.amount.value,
      amount: BigDecimal("0.53"),
      created_at: Time.zone.parse("2023-03-26 07:55:13")
    )
    merchant_e_order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_e.id.value,
      disbursement_id: nil,
      amount: BigDecimal("2.99"),
      created_at: Time.zone.parse("2023-03-26 19:24:13")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_e_order_2.id.value,
      order_amount: merchant_e_order_2.amount.value,
      amount: BigDecimal("0.03"),
      created_at: Time.zone.parse("2023-03-26 19:25:03")
    )
    merchant_e_order_3 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
      merchant_id: merchant_e.id.value,
      disbursement_id: nil,
      amount: BigDecimal("10.99"),
      created_at: Time.zone.parse("2023-03-31 16:24:03")
    )
    PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
      order_id: merchant_e_order_3.id.value,
      order_amount: merchant_e_order_3.amount.value,
      amount: BigDecimal("0.11"),
      created_at: Time.zone.parse("2023-03-31 16:24:13")
    )

    task.invoke

    repository = PaymentsContext::Disbursements::Repositories::PostgresDisbursementRepository.new
    disbursements = repository.all.map do |d|
      [
        d.merchant_id.value,
        d.amount.value.amount,
        d.commissions_amount.value.amount,
        d.order_ids.value
      ]
    end

    expect(disbursements).to contain_exactly(
      [
        merchant_b.id.value,
        BigDecimal("317.24"),
        BigDecimal("2.73"),
        [merchant_b_order_1.id.value, merchant_b_order_2.id.value]
      ],
      [
        merchant_b.id.value,
        BigDecimal("261.13"),
        BigDecimal("2.49"),
        [merchant_b_order_3.id.value]
      ],
      [
        merchant_c.id.value,
        BigDecimal("490.24"),
        BigDecimal("4.32"),
        [merchant_c_order_1.id.value, merchant_c_order_2.id.value]
      ],
      [
        merchant_d.id.value,
        BigDecimal("1583.99"),
        BigDecimal("13.59"),
        [merchant_d_order_1.id.value, merchant_d_order_2.id.value, merchant_d_order_3.id.value]
      ],
      [
        merchant_d.id.value,
        BigDecimal("50.0"),
        BigDecimal("0.48"),
        [merchant_d_order_4.id.value]
      ],
      [
        merchant_e.id.value,
        BigDecimal("57.98"),
        BigDecimal("0.56"),
        [merchant_e_order_1.id.value, merchant_e_order_2.id.value]
      ]
    )
  end
end
