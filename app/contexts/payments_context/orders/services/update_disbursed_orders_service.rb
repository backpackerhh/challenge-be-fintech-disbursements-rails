# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Services
      class UpdateDisbursedOrdersService
        attr_reader :repository

        def initialize(repository: Repositories::PostgresOrderRepository.new)
          @repository = repository
        end

        def update_all(order_ids, disbursement_id)
          repository.bulk_update_disbursed(order_ids, disbursement_id)
        end
      end
    end
  end
end
