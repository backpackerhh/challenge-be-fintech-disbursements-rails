# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Services
      class CalculateMonthlyOrderCommissionsAmountService
        attr_reader :repository

        def initialize(repository: Repositories::PostgresOrderCommissionRepository.new)
          @repository = repository
        end

        def calculate(merchant_id, date)
          repository.calculate_monthly_amount(merchant_id, date)
        end
      end
    end
  end
end
