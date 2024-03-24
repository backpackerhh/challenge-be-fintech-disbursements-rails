# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Repositories
      class InMemoryDisbursementRepository
        def all; end

        def create(_attributes); end

        def size; end

        def find_all_grouped_disbursable_ids; end
      end
    end
  end
end
