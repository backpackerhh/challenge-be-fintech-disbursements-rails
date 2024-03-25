# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module UseCases
      class CreateMerchantUseCase
        attr_reader :repository, :logger

        def initialize(repository: Repositories::PostgresMerchantRepository.new, logger: Rails.logger)
          @repository = repository
          @logger = logger
        end

        def create(attributes)
          merchant = Entities::MerchantEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(merchant.to_primitives)

          logger.info("Merchant #{merchant.id.value} successfully created")
        end
      end
    end
  end
end
