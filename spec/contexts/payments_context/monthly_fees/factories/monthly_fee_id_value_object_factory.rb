# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Factories
      class MonthlyFeeIdValueObjectFactory
        def self.build(value = SecureRandom.uuid)
          value
        end
      end
    end
  end
end
