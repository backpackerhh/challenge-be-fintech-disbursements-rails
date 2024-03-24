# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Services
      class GroupAllDisbursableOrdersService
        attr_reader :repository

        def initialize(repository: Repositories::PostgresOrderRepository.new)
          @repository = repository
        end

        def group(grouping_type, merchant_id)
          repository.group_all_disbursable(grouping_type, merchant_id)
        end
      end
    end
  end
end
