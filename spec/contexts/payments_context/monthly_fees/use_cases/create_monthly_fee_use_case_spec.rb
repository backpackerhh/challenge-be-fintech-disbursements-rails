# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::MonthlyFees::UseCases::CreateMonthlyFeeUseCase, type: :use_case do
  describe "#create(attributes)" do
    let(:repository) { PaymentsContext::MonthlyFees::Repositories::InMemoryMonthlyFeeRepository.new }
    let(:attributes) do
      {
        "id" => "0df9c70e-142f-4960-859f-30aa14f8e103",
        "merchant_id" => "86312006-4d7e-45c4-9c28-788f4aa68a62",
        "amount" => "10.29",
        "commissions_amount" => "4.71",
        "month" => "2023-04"
      }
    end

    context "with valid attributes" do
      it "creates monthly fee" do
        expect(repository).to receive(:create).with(
          {
            id: "0df9c70e-142f-4960-859f-30aa14f8e103",
            merchant_id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
            amount: BigDecimal("10.29"),
            commissions_amount: BigDecimal("4.71"),
            month: "2023-04"
          }
        )

        described_class.new(repository:).create(attributes)
      end
    end

    context "with invalid attributes" do
      it "does not create monthly fee (invalid ID)" do
        expect do
          described_class.new(repository:).create(attributes.merge("id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create monthly fee (invalid merchant ID)" do
        expect do
          described_class.new(repository:).create(attributes.merge("merchant_id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create monthly fee (invalid amount)" do
        expect do
          described_class.new(repository:).create(attributes.merge("amount" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end

      it "does not create monthly fee (invalid commissions amount)" do
        expect do
          described_class.new(repository:).create(attributes.merge("commissions_amount" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end

      it "does not create monthly fee (invalid month)" do
        expect do
          described_class.new(repository:).create(attributes.merge("month" => "2023/04"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+format.+failed/)
      end
    end
  end
end
