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
      it "creates a new order" do
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
end
