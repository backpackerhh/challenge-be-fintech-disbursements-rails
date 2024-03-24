# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Factories
      class DisbursementAmountValueObjectFactory
        def self.build(value = rand(2000))
          value
        end
      end
    end
  end
end
