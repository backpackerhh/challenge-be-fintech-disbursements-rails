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
end
