# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Jobs
      class GenerateDisbursementsJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "disbursements"

        attr_reader :find_disbursable_merchants_service, :group_disbursable_orders_job_klass

        def initialize(
          find_disbursable_merchants_service: Merchants::Services::FindAllDisbursableMerchantsService.new,
          group_disbursable_orders_job_klass: Orders::Jobs::GroupDisbursableOrdersJob
        )
          super()
          @find_disbursable_merchants_service = find_disbursable_merchants_service
          @group_disbursable_orders_job_klass = group_disbursable_orders_job_klass
        end

        def perform
          grouped_disbursable_merchant_ids = find_disbursable_merchants_service.group_all_ids

          grouped_disbursable_merchant_ids.each do |disbursement_frequency, merchant_ids|
            merchant_ids.each do |merchant_id|
              group_disbursable_orders_job_klass.perform_async(disbursement_frequency.downcase, merchant_id)
            end
          end

          logger.info("Jobs enqueued to generate disbursements on #{Date.current}")
        end
      end
    end
  end
end
