# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::Orders::UseCases::CreateOrderUseCase, type: :use_case do
  describe "#create(attributes)" do
    let(:repository) { PaymentsContext::Orders::Repositories::InMemoryOrderRepository.new }
    let(:attributes) do
      {
        "id" => "0df9c70e-142f-4960-859f-30aa14f8e103",
        "merchant_id" => "86312006-4d7e-45c4-9c28-788f4aa68a62",
        "reference" => "e653f3e14bc4",
        "amount" => "102.29",
        "created_at" => "2023-02-01"
      }
    end

    context "with valid attributes" do
      it "creates order" do
        expect(repository).to receive(:create).with(
          {
            id: "0df9c70e-142f-4960-859f-30aa14f8e103",
            merchant_id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
            reference: "e653f3e14bc4",
            amount: 102.29,
            created_at: Time.zone.parse("2023-02-01")
          }
        )

        described_class.new(repository:).create(attributes)
      end
    end

    context "with invalid attributes" do
      it "does not create order (invalid ID)" do
        expect do
          described_class.new(repository:).create(attributes.merge("id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create order (invalid merchant ID)" do
        expect do
          described_class.new(repository:).create(attributes.merge("merchant_id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create order (invalid reference)" do
        expect do
          described_class.new(repository:).create(attributes.merge("reference" => 123))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+String.+failed/)
      end

      it "does not create order (invalid amount)" do
        expect do
          described_class.new(repository:).create(attributes.merge("amount" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+decimal failed/)
      end

      it "does not create order (invalid created at time)" do
        expect do
          described_class.new(repository:)
                         .create(attributes.merge("created_at" => "yesterday"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+time.+failed/)
      end
    end
  end
end
