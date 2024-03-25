# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module UseCases
      class CreateMonthlyFeeUseCase
        attr_reader :repository

        def initialize(repository: Repositories::PostgresMonthlyFeeRepository.new)
          @repository = repository
        end

        def create(attributes)
          monthly_fee = Entities::MonthlyFeeEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(monthly_fee.to_primitives)
        end
      end
    end
  end
end
