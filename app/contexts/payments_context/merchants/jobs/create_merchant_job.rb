# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Jobs
      class CreateMerchantJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "import_data"

        def perform(merchant_attributes)
          UseCases::CreateMerchantUseCase.new.create(merchant_attributes)

          logger.info("Merchant #{merchant_attributes[:id]} successfully created")
        end
      end
    end
  end
end
