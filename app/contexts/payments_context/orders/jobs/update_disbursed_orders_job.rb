# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Jobs
      class UpdateDisbursedOrdersJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "disbursements"

        def perform(order_ids, disbursement_id)
          Services::UpdateDisbursedOrdersService.new.update_all(order_ids, disbursement_id)

          logger.info("Disbursed orders for disbursement #{disbursement_id} successfully updated")
        end
      end
    end
  end
end
