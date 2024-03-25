# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Services
      class FindMerchantService
        attr_reader :repository

        def initialize(repository: Repositories::PostgresMerchantRepository.new)
          @repository = repository
        end

        def find(id)
          repository.find_by_id(id)
        end
      end
    end
  end
end
