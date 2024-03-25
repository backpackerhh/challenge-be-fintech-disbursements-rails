# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::OrderCommissions::Repositories::PostgresOrderCommissionRepository,
               type: %i[repository database] do
  describe "#create(attributes)" do
    context "with order not found" do
      it "raises an exception" do
        repository = described_class.new
        order_commission = PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.build

        expect do
          repository.create(order_commission.to_primitives)
        end.to raise_error(SharedContext::Errors::RecordNotFoundError)
      end
    end

    context "with duplicated record" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value
        )
        order_commission = PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order.id.value
        )

        expect do
          repository.create(order_commission.to_primitives)
        end.to raise_error(SharedContext::Errors::DuplicatedRecordError)
      end
    end

    context "with invalid attribute" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value
        )
        order_commission = PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
          order_id: order.id.value
        )

        expect do
          repository.create(order_commission.to_primitives.merge(id: "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError)
      end
    end

    context "without errors" do
      it "creates a new order commission" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
          merchant_id: merchant.id.value
        )
        order_commission = PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.build(
          order_id: order.id.value
        )

        expect do
          repository.create(order_commission.to_primitives)
        end.to(change { repository.size }.from(0).to(1))
      end
    end
  end

  describe "#calculate_monthly_amount(merchant_id, date)" do
    it "returns 0.0 for a merchant without any orders" do
      repository = described_class.new

      result = repository.calculate_monthly_amount(SecureRandom.uuid, Date.current)

      expect(result).to eq(0.0)
    end

    it "returns the commissions amount in the month for a merchant" do
      repository = described_class.new
      merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
      another_merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
      march_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
        merchant_id: merchant.id.value,
        created_at: Time.zone.parse("2023-03-31")
      )
      PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
        order_id: march_order_1.id.value,
        order_amount: march_order_1.amount.value,
        amount: BigDecimal("0.45")
      )
      april_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
        merchant_id: merchant.id.value,
        created_at: Time.zone.parse("2023-04-01")
      )
      PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
        order_id: april_order_1.id.value,
        order_amount: april_order_1.amount.value,
        amount: BigDecimal("1.35")
      )
      april_order_2 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
        merchant_id: merchant.id.value,
        created_at: Time.zone.parse("2023-04-30")
      )
      PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
        order_id: april_order_2.id.value,
        order_amount: april_order_2.amount.value,
        amount: BigDecimal("2.31")
      )
      another_merchant_april_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
        merchant_id: another_merchant.id.value,
        created_at: Time.zone.parse("2023-04-01")
      )
      PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
        order_id: another_merchant_april_order_1.id.value,
        order_amount: another_merchant_april_order_1.amount.value,
        amount: BigDecimal("1.58")
      )
      may_order_1 = PaymentsContext::Orders::Factories::OrderEntityFactory.create(
        merchant_id: merchant.id.value,
        created_at: Time.zone.parse("2023-05-01")
      )
      PaymentsContext::OrderCommissions::Factories::OrderCommissionEntityFactory.create(
        order_id: may_order_1.id.value,
        order_amount: may_order_1.amount.value,
        amount: BigDecimal("0.08")
      )

      monthly_amount = repository.calculate_monthly_amount(merchant.id.value, Date.parse("2023-04-01"))

      expect(monthly_amount).to eq(3.66)
    end
  end
end
