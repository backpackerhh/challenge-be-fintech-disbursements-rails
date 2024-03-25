# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Jobs
      class GroupDisbursableOrdersJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "disbursements"

        attr_reader :create_disbursement_job_klass

        def initialize(create_disbursement_job_klass: Disbursements::Jobs::CreateDisbursementJob)
          super()
          @create_disbursement_job_klass = create_disbursement_job_klass
        end

        def perform(grouping_type, merchant_id)
          grouped_disbursable_orders = Services::GroupAllDisbursableOrdersService.new.group(grouping_type, merchant_id)

          grouped_disbursable_orders.each_with_index do |disbursement_attributes, idx|
            delay = idx * 5 # in seconds
            attributes = disbursement_attributes.merge(
              "merchant_id" => merchant_id,
              "order_ids" => JSON.parse(disbursement_attributes["order_ids"]),
              "amount" => disbursement_attributes["amount"].to_s,
              "commissions_amount" => disbursement_attributes["commissions_amount"].to_s
            )

            create_disbursement_job_klass.perform_in(delay, attributes)
          end

          logger.info("Disbursable orders grouped for merchant #{merchant_id}")
        end
      end
    end
  end
end
