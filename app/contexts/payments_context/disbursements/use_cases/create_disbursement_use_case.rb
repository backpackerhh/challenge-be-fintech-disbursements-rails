# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module UseCases
      class CreateDisbursementUseCase
        attr_reader :repository, :update_disbursed_orders_job_klass, :create_monthly_fee_job_klass, :logger

        def initialize(
          repository: Repositories::PostgresDisbursementRepository.new,
          update_disbursed_orders_job_klass: Orders::Jobs::UpdateDisbursedOrdersJob,
          create_monthly_fee_job_klass: MonthlyFees::Jobs::CreateMonthlyFeeJob,
          logger: Rails.logger
        )
          @repository = repository
          @update_disbursed_orders_job_klass = update_disbursed_orders_job_klass
          @create_monthly_fee_job_klass = create_monthly_fee_job_klass
          @logger = logger
        end

        def create(attributes)
          disbursement = Entities::DisbursementEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(disbursement.to_primitives)

          logger.info("Disbursement #{disbursement.id.value} successfully created")

          # FIXME: replace with domain events to avoid coupling between modules
          update_disbursed_orders_job_klass.perform_async(disbursement.order_ids.value, disbursement.id.value)

          if repository.first_in_month_for_merchant?(disbursement.merchant_id.value, disbursement.start_date.value)
            create_monthly_fee_job_klass.perform_async(
              disbursement.merchant_id.value,
              disbursement.start_date.value.to_s
            )
          end
        end
      end
    end
  end
end
