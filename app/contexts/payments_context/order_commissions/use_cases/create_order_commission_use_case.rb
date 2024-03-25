# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module UseCases
      class CreateOrderCommissionUseCase
        attr_reader :repository, :logger

        def initialize(repository: Repositories::PostgresOrderCommissionRepository.new, logger: Rails.logger)
          @repository = repository
          @logger = logger
        end

        def create(attributes)
          order_commission = Entities::OrderCommissionEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(order_commission.to_primitives)

          logger.info("Order commission for order #{order_commission.order_id.value} successfully created")
        end
      end
    end
  end
end
