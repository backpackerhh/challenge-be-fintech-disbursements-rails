# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::Merchants::Repositories::PostgresMerchantRepository, type: %i[repository database] do
  describe "#all" do
    it "returns empty array without any merchants" do
      repository = described_class.new

      merchants = repository.all

      expect(merchants).to eq([])
    end

    it "returns all merchants" do
      repository = described_class.new
      merchant_a = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "A")
      merchant_b = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "B")

      merchants = repository.all

      expect(merchants).to contain_exactly(merchant_a, merchant_b)
    end
  end

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

  describe "#find_all_grouped_disbursable_ids" do
    it "returns all disbursable merchant IDs grouped by disbursement frequency",
       freeze_time: Time.zone.parse("2023-04-14 07:00:00") do
      repository = described_class.new
      merchant_a = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(:daily_disbursement)
      merchant_b = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(:daily_disbursement)
      merchant_c = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
        :weekly_disbursement,
        live_on: Date.parse("2023-04-06")
      )
      merchant_d = PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(
        :weekly_disbursement,
        live_on: Date.parse("2023-04-07")
      )

      grouped_disbursable_merchant_ids = repository.find_all_grouped_disbursable_ids

      expect(grouped_disbursable_merchant_ids).to eq(
        {
          PaymentsContext::Merchants::Factories::MerchantDisbursementFrequencyValueObjectFactory.daily => [
            merchant_a.id.value,
            merchant_b.id.value
          ],
          PaymentsContext::Merchants::Factories::MerchantDisbursementFrequencyValueObjectFactory.weekly => [
            merchant_d.id.value
          ]
        }
      )
    end
  end
end
