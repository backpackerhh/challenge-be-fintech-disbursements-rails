# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module UseCases
      class CreateDisbursementUseCase
        attr_reader :repository

        def initialize(repository: Repositories::PostgresDisbursementRepository.new)
          @repository = repository
        end

        def create(attributes)
          disbursement = Entities::DisbursementEntity.from_primitives(attributes.transform_keys(&:to_sym))

          repository.create(disbursement.to_primitives)
        end
      end
    end
  end
end
