# frozen_string_literal: true

require "spec_helper"

RSpec.describe PaymentsContext::Disbursements::Repositories::PostgresDisbursementRepository,
               type: %i[repository database] do
  describe "#all" do
    it "returns empty array without any disbursements" do
      repository = described_class.new

      disbursements = repository.all

      expect(disbursements).to eq([])
    end

    it "returns all disbursements" do
      repository = described_class.new
      merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
      disbursement_a = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
        merchant_id: merchant.id.value
      )
      disbursement_b = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
        merchant_id: merchant.id.value
      )

      disbursements = repository.all

      expect(disbursements).to contain_exactly(disbursement_a, disbursement_b)
    end
  end

  describe "#create(attributes)" do
    context "with merchant not found" do
      it "raises an exception" do
        repository = described_class.new
        order = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.build

        expect do
          repository.create(order.to_primitives)
        end.to raise_error(SharedContext::Errors::RecordNotFoundError)
      end
    end

    context "with duplicated record" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(order.to_primitives)
        end.to raise_error(SharedContext::Errors::DuplicatedRecordError)
      end
    end

    context "with invalid attribute" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.build(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(order.to_primitives.merge(id: "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError)
      end
    end

    context "without errors" do
      it "creates a new order" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        order = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.build(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(order.to_primitives)
        end.to(change { repository.size }.from(0).to(1))
      end
    end
  end
end
