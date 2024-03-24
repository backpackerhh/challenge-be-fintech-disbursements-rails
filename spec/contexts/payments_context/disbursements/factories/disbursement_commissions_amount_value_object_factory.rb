# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Factories
      class DisbursementCommissionsAmountValueObjectFactory
        def self.build(value = rand(2000), percentage = 0.15)
          value * percentage
        end
      end
    end
  end
end
