# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module UseCases
      class CreateOrderCommissionUseCase
        attr_reader :repository

        def initialize(repository: Repositories::PostgresOrderCommissionRepository.new)
          @repository = repository
        end

        def create(attributes)
          order_commission = Entities::OrderCommissionEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(order_commission.to_primitives)
        end
      end
    end
  end
end
