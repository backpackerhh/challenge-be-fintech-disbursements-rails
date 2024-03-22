# frozen_string_literal: true

module PaymentsContext
  module Orders
    module UseCases
      class CreateOrderUseCase
        attr_reader :repository

        def initialize(repository: Repositories::PostgresOrderRepository.new)
          @repository = repository
        end

        def create(attributes)
          order = Entities::OrderEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(order.to_primitives)
        end
      end
    end
  end
end
