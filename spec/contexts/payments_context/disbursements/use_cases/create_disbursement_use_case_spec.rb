# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::Disbursements::UseCases::CreateDisbursementUseCase, type: :use_case do
  describe "#create(attributes)" do
    let(:repository) { PaymentsContext::Disbursements::Repositories::InMemoryDisbursementRepository.new }
    let(:update_disbursed_orders_job_klass) { PaymentsContext::Orders::Jobs::UpdateDisbursedOrdersJob }
    let(:create_monthly_fee_job_klass) { PaymentsContext::MonthlyFees::Jobs::CreateMonthlyFeeJob }
    let(:attributes) do
      {
        "id" => "93711b5b-0f08-49d9-b819-322d83801d09",
        "merchant_id" => "86312006-4d7e-45c4-9c28-788f4aa68a62",
        "order_ids" => %w[9dc5d490-e823-455b-a6b0-645b3f8aeee3 2d32fd3f-e149-44d1-b0bc-176e28241f78],
        "reference" => "FegBgohOER0N",
        "amount" => "102.29",
        "commissions_amount" => "1.01",
        "start_date" => "2023-01-31",
        "end_date" => "2023-01-31"
      }
    end

    context "with valid attributes" do
      it "creates disbursement" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect(repository).to receive(:create).with(
          {
            id: "93711b5b-0f08-49d9-b819-322d83801d09",
            merchant_id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
            order_ids: %w[9dc5d490-e823-455b-a6b0-645b3f8aeee3 2d32fd3f-e149-44d1-b0bc-176e28241f78],
            reference: "FegBgohOER0N",
            amount: BigDecimal("102.29"),
            commissions_amount: BigDecimal("1.01"),
            start_date: Date.parse("2023-01-31"),
            end_date: Date.parse("2023-01-31")
          }
        )

        use_case.create(attributes)
      end

      it "enqueues job to update disbursed orders" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect(update_disbursed_orders_job_klass).to receive(:perform_async).with(
          %w[9dc5d490-e823-455b-a6b0-645b3f8aeee3 2d32fd3f-e149-44d1-b0bc-176e28241f78],
          "93711b5b-0f08-49d9-b819-322d83801d09"
        )

        use_case.create(attributes)
      end

      it "enqueues job to create monthly fee when merchant only has one disbursement in the month" do
        allow(repository).to receive(:first_in_month_for_merchant?)
          .with("86312006-4d7e-45c4-9c28-788f4aa68a62", Date.parse("2023-01-31")).and_return(true)

        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect(create_monthly_fee_job_klass).to receive(:perform_async).with(
          "86312006-4d7e-45c4-9c28-788f4aa68a62",
          "2023-01-31"
        )

        use_case.create(attributes)
      end

      it "does not enqueue job to create monthly fee when merchant has multiple disbursements in the month" do
        allow(repository).to receive(:first_in_month_for_merchant?)
          .with("86312006-4d7e-45c4-9c28-788f4aa68a62", Date.parse("2023-01-31")).and_return(false)

        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect(create_monthly_fee_job_klass).not_to receive(:perform_async)

        use_case.create(attributes)
      end
    end

    context "with invalid attributes" do
      it "does not create disbursement (invalid ID)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create disbursement (invalid merchant ID)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("merchant_id" => "uuid"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+uuid_v4.+failed/)
      end

      it "does not create disbursement (invalid order IDs)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("order_ids" => [1, 2]))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /Array.+invalid type.+uuid_v4.+failed/)
      end

      it "does not create disbursement (invalid reference)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("reference" => "123"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+size.+failed/)
      end

      it "does not create disbursement (invalid amount)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("amount" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end

      it "does not create disbursement (invalid commissions amount)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("commissions_amount" => "free"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+coerced to decimal.+failed/)
      end

      it "does not create disbursement (invalid start date)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("start_date" => "yesterday"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+date failed/)
      end

      it "does not create disbursement (invalid end date)" do
        use_case = described_class.new(repository:, update_disbursed_orders_job_klass:, create_monthly_fee_job_klass:)

        expect do
          use_case.create(attributes.merge("end_date" => "yesterday"))
        end.to raise_error(SharedContext::Errors::InvalidArgumentError, /invalid type.+date failed/)
      end
    end
  end
end
