# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Jobs
      class CreateOrderJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "import_data"

        def perform(order_attributes)
          UseCases::CreateOrderUseCase.new.create(order_attributes)

          logger.info("Order #{order_attributes['id']} successfully created")
        end
      end
    end
  end
end
