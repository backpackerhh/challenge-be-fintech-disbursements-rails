# frozen_string_literal: true

module PaymentsContext
  module Orders
    module Factories
      class OrderAmountValueObjectFactory
        def self.build(value = rand(200))
          value
        end
      end
    end
  end
end
