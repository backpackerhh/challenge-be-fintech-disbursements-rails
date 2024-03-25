# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::MonthlyFees::Repositories::PostgresMonthlyFeeRepository,
               type: %i[repository database] do
  describe "#all" do
    it "returns empty array without any monthly fees" do
      repository = described_class.new

      monthly_fees = repository.all

      expect(monthly_fees).to eq([])
    end

    it "returns all monthly fees" do
      repository = described_class.new
      merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
      monthly_fee_a = PaymentsContext::MonthlyFees::Factories::MonthlyFeeEntityFactory.create(
        merchant_id: merchant.id.value
      )
      monthly_fee_b = PaymentsContext::MonthlyFees::Factories::MonthlyFeeEntityFactory.create(
        merchant_id: merchant.id.value
      )

      monthly_fees = repository.all

      expect(monthly_fees).to contain_exactly(monthly_fee_a, monthly_fee_b)
    end
  end

  describe "#create(attributes)" do
    context "with merchant not found" do
      it "raises an exception" do
        repository = described_class.new
        monthly_fee = PaymentsContext::MonthlyFees::Factories::MonthlyFeeEntityFactory.build

        expect do
          repository.create(monthly_fee.to_primitives)
        end.to raise_error(SharedContext::Errors::RecordNotFoundError)
      end
    end

    context "with duplicated record" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        monthly_fee = PaymentsContext::MonthlyFees::Factories::MonthlyFeeEntityFactory.create(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(monthly_fee.to_primitives)
        end.to raise_error(SharedContext::Errors::DuplicatedRecordError)
      end
    end

    context "with invalid attribute" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        monthly_fee = PaymentsContext::MonthlyFees::Factories::MonthlyFeeEntityFactory.create(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(monthly_fee.to_primitives.merge(id: "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError)
      end
    end

    context "without errors" do
      it "creates a new monthly fee" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        monthly_fee = PaymentsContext::MonthlyFees::Factories::MonthlyFeeEntityFactory.build(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(monthly_fee.to_primitives)
        end.to(change { repository.size }.from(0).to(1))
      end
    end
  end
end
