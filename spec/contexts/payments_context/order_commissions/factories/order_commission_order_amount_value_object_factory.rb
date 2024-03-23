# frozen_string_literal: true

module PaymentsContext
  module OrderCommissions
    module Factories
      class OrderCommissionOrderAmountValueObjectFactory
        def self.build(value = Money.new(rand(2000)))
          value
        end
      end
    end
  end
end
