# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module Factories
      class DisbursementReferenceValueObjectFactory
        def self.build(value = Faker::Alphanumeric.alpha(number: 12))
          value
        end
      end
    end
  end
end
