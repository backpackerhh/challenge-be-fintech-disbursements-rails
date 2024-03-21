# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::Merchants::UseCases::CreateMerchantUseCase, type: :use_case do
  describe "#create(attributes)" do
    let(:repository) { PaymentsContext::Merchants::Repositories::InMemoryMerchantRepository.new }
    let(:attributes) do
      {
        id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
        reference: "padberg_group",
        email: "info@padberg-group.com",
        live_on: "2023-02-01",
        disbursement_frequency: "DAILY",
        minimum_monthly_fee: "0.0"
      }
    end

    context "with valid attributes" do
      it "creates merchant", :freeze_time do
        expect(repository).to receive(:create).with(
          {
            id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
            reference: "padberg_group",
            email: "info@padberg-group.com",
            live_on: Date.parse("2023-02-01"),
            disbursement_frequency: "DAILY",
            minimum_monthly_fee: 0.0,
            created_at: Time.current
          }
        )

        described_class.new(repository:).create(attributes)
      end
    end

    context "with invalid attributes" do
      it "does not create merchant (invalid ID)" do
        expect do
          described_class.new(repository:).create(attributes.merge(id: "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create merchant (invalid email)" do
        expect do
          described_class.new(repository:).create(attributes.merge(email: "email"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+format.+failed/)
      end

      it "does not create merchant (invalid live on date)" do
        expect do
          described_class.new(repository:).create(attributes.merge(live_on: "yesterday"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+date failed/)
      end

      it "does not create merchant (invalid disbursement frequency)" do
        expect do
          described_class.new(repository:).create(attributes.merge(disbursement_frequency: "YEARLY"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+included_in.+failed/)
      end

      it "does not create merchant (invalid minimum monthly fee)" do
        expect do
          described_class.new(repository:).create(attributes.merge(minimum_monthly_fee: "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end

      it "does not create merchant (invalid created at time)" do
        expect do
          described_class.new(repository:).create(attributes.merge(created_at: "yesterday"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+time.+failed/)
      end
    end
  end
end
