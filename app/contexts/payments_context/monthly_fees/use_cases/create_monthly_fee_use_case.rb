# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module UseCases
      class CreateMonthlyFeeUseCase
        attr_reader :repository, :logger

        def initialize(repository: Repositories::PostgresMonthlyFeeRepository.new, logger: Rails.logger)
          @repository = repository
          @logger = logger
        end

        def create(attributes)
          monthly_fee = Entities::MonthlyFeeEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(monthly_fee.to_primitives)

          logger.info("Monthly fee #{monthly_fee.id.value} successfully created")
        end
      end
    end
  end
end
