# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Factories
      class DisbursementIdValueObjectFactory
        def self.build(value = SecureRandom.uuid)
          value
        end
      end
    end
  end
end
