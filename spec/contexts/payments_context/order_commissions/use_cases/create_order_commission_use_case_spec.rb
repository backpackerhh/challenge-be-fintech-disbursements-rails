# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::OrderCommissions::UseCases::CreateOrderCommissionUseCase, type: :use_case do
  describe "#create(attributes)" do
    let(:repository) { PaymentsContext::OrderCommissions::Repositories::InMemoryOrderCommissionRepository.new }
    let(:attributes) do
      {
        "id" => "d1649242-a612-46ba-82d8-225542bb9576",
        "order_id" => "86312006-4d7e-45c4-9c28-788f4aa68a62",
        "order_amount" => "102.29"
      }
    end

    context "with valid attributes" do
      it "creates order commission with tier 1 fee" do
        use_case = described_class.new(repository:)

        expect(repository).to receive(:create).with(
          {
            id: "d1649242-a612-46ba-82d8-225542bb9576",
            order_id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
            order_amount: BigDecimal("49.99"),
            amount: BigDecimal("0.5"),
            fee: BigDecimal("1.0")
          }
        )

        use_case.create(attributes.merge("order_amount" => BigDecimal("49.99")))
      end

      it "creates order commission with tier 2 fee" do
        use_case = described_class.new(repository:)

        expect(repository).to receive(:create).with(
          {
            id: "d1649242-a612-46ba-82d8-225542bb9576",
            order_id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
            order_amount: BigDecimal("299.99"),
            amount: BigDecimal("2.85"),
            fee: BigDecimal("0.95")
          }
        )

        use_case.create(attributes.merge("order_amount" => BigDecimal("299.99")))
      end

      it "creates order commission with tier 3 fee" do
        use_case = described_class.new(repository:)

        expect(repository).to receive(:create).with(
          {
            id: "d1649242-a612-46ba-82d8-225542bb9576",
            order_id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
            order_amount: BigDecimal("300.00"),
            amount: BigDecimal("2.55"),
            fee: BigDecimal("0.85")
          }
        )

        use_case.create(attributes.merge("order_amount" => BigDecimal("300.00")))
      end
    end

    context "with invalid attributes" do
      it "does not create order commission (invalid ID)" do
        use_case = described_class.new(repository:)

        expect do
          use_case.create(attributes.merge("id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create order commission (invalid order ID)" do
        use_case = described_class.new(repository:)

        expect do
          use_case.create(attributes.merge("order_id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create order commission (invalid order amount)" do
        use_case = described_class.new(repository:)

        expect do
          use_case.create(attributes.merge("order_amount" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end

      it "does not create order commission (invalid amount)" do
        use_case = described_class.new(repository:)

        expect do
          use_case.create(attributes.merge("amount" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end

      it "does not create order commission (invalid fee)" do
        use_case = described_class.new(repository:)

        expect do
          use_case.create(attributes.merge("fee" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end
    end
  end
end
