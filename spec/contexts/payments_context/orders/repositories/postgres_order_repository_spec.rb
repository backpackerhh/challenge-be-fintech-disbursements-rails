# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::Orders::Repositories::PostgresOrderRepository, type: %i[repository database] do
  describe "#create(attributes)" do
    context "with merchant not found" do
      it "raises an exception" do
        repository = described_class.new
        order = PaymentsContext::Orders::Factories::OrderEntityFactory.build

        expect do
          repository.create(order.to_primitives)
        end.to raise_error(SharedContext::Errors::RecordNotFoundError)
      end
    end

    context "with duplicated record" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Orders::Factories::OrderEntityFactory.create(merchant_id: merchant.id.value)

        expect do
          repository.create(order.to_primitives)
        end.to raise_error(SharedContext::Errors::DuplicatedRecordError)
      end
    end

    context "with invalid attribute" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Orders::Factories::OrderEntityFactory.build(merchant_id: merchant.id.value)

        expect do
          repository.create(order.to_primitives.merge(id: "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError)
      end
    end

    context "without errors" do
      it "creates a new order" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Orders::Factories::OrderEntityFactory.build(merchant_id: merchant.id.value)

        expect do
          repository.create(order.to_primitives)
        end.to(change { repository.size }.from(0).to(1))
      end
    end
  end

  describe "#group_all_disbursable(grouping_type, merchant_id)" do
    context "when given grouping type is not supported" do
      it "raises an exception" do
        repository = described_class.new
        merchant_id = SecureRandom.uuid

        expect do
          repository.group_all_disbursable("unknown", merchant_id)
        end.to raise_error(PaymentsContext::Orders::Errors::UnsupportedGroupingTypeError)
      end
    end

    context "when there are no orders for given merchant" do
      it "returns empty array" do
        repository = described_class.new
        merchant_id = SecureRandom.uuid

        results = repository.group_all_disbursable("daily", merchant_id)

        expect(results).to eq([])
      end
    end

    context "when there are orders for given merchant", freeze_time: Time.zone.parse("2023-04-14 07:00 UTC") do
      it "returns orders grouped by day" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
          :daily_disbursement,
          live_on: Date.parse("2022-01-06")
        )
        order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("349.99"),
          created_at: Time.zone.parse("2022-11-15 08:59:31")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_1.id.value,
          order_amount: order_1.amount.value,
          created_at: Time.zone.parse("2022-11-15 08:59:52")
        )
        order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("140.25"),
          created_at: Time.zone.parse("2022-11-15 08:59:45")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_2.id.value,
          order_amount: order_2.amount.value,
          created_at: Time.zone.parse("2022-11-15 09:00:14")
        )
        disbursement = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
          merchant_id: merchant.id.value,
          amount: BigDecimal("100.0"),
          commissions_amount: BigDecimal("1.0"),
          order_ids: []
        )
        order_3 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: disbursement.id.value,
          amount: BigDecimal("26.95"),
          created_at: Time.zone.parse("2023-01-12 07:54:03")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_3.id.value,
          order_amount: order_3.amount.value,
          created_at: Time.zone.parse("2023-01-12 07:55:13")
        )
        order_4 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("10.99"),
          created_at: Time.zone.parse("2023-04-13 23:54:03")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_4.id.value,
          order_amount: order_4.amount.value,
          created_at: Time.zone.parse("2023-04-13 23:55:13")
        )
        order_5 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("9.99"),
          created_at: Time.zone.parse("2023-04-14 06:54:03")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_5.id.value,
          order_amount: order_5.amount.value,
          created_at: Time.zone.parse("2023-04-14 06:55:13")
        )

        results = repository.group_all_disbursable("daily", merchant.id.value)

        expect(results).to eq(
          [
            {
              "amount" => BigDecimal("490.24"),
              "commissions_amount" => BigDecimal("4.32"),
              "order_ids" => "[\"#{order_1.id.value}\", \"#{order_2.id.value}\"]",
              "start_date" => "2022-11-15",
              "end_date" => "2022-11-15"
            },
            {
              "amount" => BigDecimal("10.99"),
              "commissions_amount" => BigDecimal("0.11"),
              "order_ids" => "[\"#{order_4.id.value}\"]",
              "start_date" => "2023-04-13",
              "end_date" => "2023-04-13"
            }
          ]
        )
      end

      it "returns orders grouped by week" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
          :weekly_disbursement,
          live_on: Date.parse("2022-01-06")
        )
        order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("349.99"),
          created_at: Time.zone.parse("2022-11-14 08:59:31")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_1.id.value,
          order_amount: order_1.amount.value,
          created_at: Time.zone.parse("2022-11-14 08:59:52")
        )
        order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("140.25"),
          created_at: Time.zone.parse("2022-11-15 08:59:45")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_2.id.value,
          order_amount: order_2.amount.value,
          created_at: Time.zone.parse("2022-11-15 09:00:14")
        )
        order_3 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("1399.95"),
          created_at: Time.zone.parse("2023-01-05 18:59:45")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_3.id.value,
          order_amount: order_3.amount.value,
          created_at: Time.zone.parse("2023-01-05 19:00:14")
        )
        disbursement = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
          merchant_id: merchant.id.value,
          amount: BigDecimal("100.0"),
          commissions_amount: BigDecimal("1.0"),
          order_ids: []
        )
        order_4 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: disbursement.id.value,
          amount: BigDecimal("26.95"),
          created_at: Time.zone.parse("2023-01-06 07:54:03")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_4.id.value,
          order_amount: order_4.amount.value,
          created_at: Time.zone.parse("2023-01-06 07:55:13")
        )
        order_5 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("10.99"),
          created_at: Time.zone.parse("2023-04-13 23:54:03")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_5.id.value,
          order_amount: order_5.amount.value,
          created_at: Time.zone.parse("2023-04-13 23:55:13")
        )
        order_6 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value,
          disbursement_id: nil,
          amount: BigDecimal("9.99"),
          created_at: Time.zone.parse("2023-04-14 06:54:03")
        )
        PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order_6.id.value,
          order_amount: order_6.amount.value,
          created_at: Time.zone.parse("2023-04-14 06:55:13")
        )

        results = repository.group_all_disbursable("weekly", merchant.id.value)

        expect(results).to eq(
          [
            {
              "amount" => BigDecimal("490.24"),
              "commissions_amount" => BigDecimal("4.32"),
              "order_ids" => "[\"#{order_1.id.value}\", \"#{order_2.id.value}\"]",
              "start_date" => "2022-11-14",
              "end_date" => "2022-11-20"
            },
            {
              "amount" => BigDecimal("1399.95"),
              "commissions_amount" => BigDecimal("11.90"),
              "order_ids" => "[\"#{order_3.id.value}\"]",
              "start_date" => "2023-01-02",
              "end_date" => "2023-01-08"
            }
          ]
        )
      end
    end
  end
end
