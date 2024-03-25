# frozen_string_literal: true

module PaymentsContext
  module Orders
    module UseCases
      class CreateOrderUseCase
        attr_reader :repository, :create_order_commission_job_klass, :logger

        def initialize(
          repository: Repositories::PostgresOrderRepository.new,
          create_order_commission_job_klass: OrderCommissions::Jobs::CreateOrderCommissionJob,
          logger: Rails.logger
        )
          @repository = repository
          @create_order_commission_job_klass = create_order_commission_job_klass
          @logger = logger
        end

        def create(attributes)
          order = Entities::OrderEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(order.to_primitives)

          logger.info("Order #{order.id.value} successfully created")

          # FIXME: replace with domain events to avoid coupling between modules
          create_order_commission_job_klass.perform_async(order.id.value, order.amount.value.to_s)
        end
      end
    end
  end
end
