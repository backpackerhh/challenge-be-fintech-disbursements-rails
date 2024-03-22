# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Repositories
      class InMemoryOrderRepository
        def create(_attributes); end

        def size; end
      end
    end
  end
end
