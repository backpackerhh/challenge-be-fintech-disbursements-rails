# frozen_string_literal: true

require "spec_helper"

RSpec.describe PaymentsContext::Merchants::Repositories::PostgresMerchantRepository, type: %i[repository database] do
  describe "#create(attributes)" do
    context "with duplicated record" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create

        expect do
          repository.create(merchant.to_primitives)
        end.to raise_error(SharedContext::Errors::DuplicatedRecordError)
      end
    end

    context "with invalid attribute" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.build

        expect do
          repository.create(merchant.to_primitives.merge(id: "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError)
      end
    end

    context "without errors" do
      it "creates a new merchant" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.build

        expect do
          repository.create(merchant.to_primitives)
        end.to(change { repository.size }.from(0).to(1))
      end
    end
  end
end
