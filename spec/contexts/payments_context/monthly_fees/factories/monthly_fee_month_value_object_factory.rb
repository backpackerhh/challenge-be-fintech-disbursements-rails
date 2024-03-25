# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Factories
      class MonthlyFeeMonthValueObjectFactory
        def self.build(value = Time.current)
          value.strftime("%Y-%m")
        end
      end
    end
  end
end
