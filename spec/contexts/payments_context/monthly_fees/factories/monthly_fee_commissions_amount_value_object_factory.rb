# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Factories
      class MonthlyFeeCommissionsAmountValueObjectFactory
        def self.build(value = rand(20), percentage = 0.15)
          value * percentage
        end
      end
    end
  end
end
