# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Services
      class FindAllDisbursableMerchantsService
        attr_reader :repository

        def initialize(repository: Repositories::PostgresMerchantRepository.new)
          @repository = repository
        end

        def group_all_ids
          repository.find_all_grouped_disbursable_ids
        end
      end
    end
  end
end
