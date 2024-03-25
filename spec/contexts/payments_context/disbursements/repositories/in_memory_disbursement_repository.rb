# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Repositories
      class InMemoryDisbursementRepository
        def all; end

        def create(_attributes); end

        def size; end

        def find_all_grouped_disbursable_ids; end

        def first_in_month_for_merchant?(_merchant_id, _date); end
      end
    end
  end
end
