# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module UseCases
      class CreateMerchantUseCase
        attr_reader :repository

        def initialize(repository: Repositories::PostgresMerchantRepository.new)
          @repository = repository
        end

        def create(attributes)
          merchant = Entities::MerchantEntity.from_primitives(attributes)

          repository.create(merchant.to_primitives)
        end
      end
    end
  end
end
