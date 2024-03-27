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
        disbursement = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.build

        expect do
          repository.create(disbursement.to_primitives)
        end.to raise_error(SharedContext::Errors::RecordNotFoundError)
      end
    end

    context "with duplicated record" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        disbursement = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(disbursement.to_primitives)
        end.to raise_error(SharedContext::Errors::DuplicatedRecordError)
      end
    end

    context "with invalid attribute" do
      it "raises an exception" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        disbursement = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.build(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(disbursement.to_primitives.merge(id: "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError)
      end
    end

    context "without errors" do
      it "creates a new disbursement" do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        disbursement = PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.build(
          merchant_id: merchant.id.value
        )

        expect do
          repository.create(disbursement.to_primitives)
        end.to(change { repository.size }.from(0).to(1))
      end
    end
  end

  describe "#first_in_month_for_merchant?(merchant_id, date)" do
    context "when there is no results for given merchant" do
      it "returns false", freeze_time: Time.zone.parse("2023-04-01 07:00") do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create

        result = repository.first_in_month_for_merchant?(merchant.id.value, Date.parse("2023-02-11"))

        expect(result).to be false
      end
    end

    context "when there is more than one result for given merchant" do
      it "returns false", freeze_time: Time.zone.parse("2023-04-01 07:00") do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
          merchant_id: merchant.id.value,
          start_date: Date.parse("2023-02-01"),
          end_date: Date.parse("2023-02-01")
        )
        PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
          merchant_id: merchant.id.value,
          start_date: Date.parse("2023-02-08"),
          end_date: Date.parse("2023-02-08")
        )

        result = repository.first_in_month_for_merchant?(merchant.id.value, Date.parse("2023-02-11"))

        expect(result).to be false
      end
    end

    context "when there is exactly one result for given merchant" do
      it "returns true", freeze_time: Time.zone.parse("2023-04-01 07:00") do
        repository = described_class.new
        merchant = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create
        PaymentsContext::Disbursements::Factories::DisbursementEntityFactory.create(
          merchant_id: merchant.id.value,
          start_date: Date.parse("2023-02-01"),
          end_date: Date.parse("2023-02-01")
        )

        result = repository.first_in_month_for_merchant?(merchant.id.value, Date.parse("2023-02-11"))

        expect(result).to be true
      end
    end
  end
end
