# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Services
      class FindAllMerchantsService
        attr_reader :repository

        def initialize(repository: Repositories::PostgresMerchantRepository.new)
          @repository = repository
        end

        def find_all
          repository.all
        end
      end
    end
  end
end
