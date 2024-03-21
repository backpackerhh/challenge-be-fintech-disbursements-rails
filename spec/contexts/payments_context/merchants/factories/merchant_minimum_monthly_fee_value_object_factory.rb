# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantMinimumMonthlyFeeFactory
        def self.build(value = rand(20))
          value
        end
      end
    end
  end
end
