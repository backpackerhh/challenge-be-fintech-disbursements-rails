# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Factories
      class DisbursementEndDateValueObjectFactory
        def self.build(value = Date.yesterday)
          value
        end
      end
    end
  end
end
