# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Factories
      class DisbursementStartDateValueObjectFactory
        def self.build(value = Date.yesterday)
          value
        end
      end
    end
  end
end
