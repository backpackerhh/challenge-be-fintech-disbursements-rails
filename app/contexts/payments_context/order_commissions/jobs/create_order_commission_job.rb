# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Jobs
      class CreateOrderCommissionJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "default"

        def perform(order_id, order_amount)
          UseCases::CreateOrderCommissionUseCase.new.create(
            "order_id" => order_id,
            "order_amount" => order_amount.to_d
          )

          logger.info("Order commission for order #{order_id} successfully created")
        end
      end
    end
  end
end
