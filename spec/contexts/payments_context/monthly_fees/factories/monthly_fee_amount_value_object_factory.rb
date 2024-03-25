# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Factories
      class MonthlyFeeAmountValueObjectFactory
        def self.build(value = rand(2000))
          value
        end
      end
    end
  end
end
