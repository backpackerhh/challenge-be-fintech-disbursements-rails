# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Jobs
      class CreateDisbursementJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "disbursements"

        def perform(disbursement_attributes)
          UseCases::CreateDisbursementUseCase.new.create(disbursement_attributes)

          logger.info("Disbursement for merchant #{disbursement_attributes['merchant_id']} successfully created")
        end
      end
    end
  end
end
