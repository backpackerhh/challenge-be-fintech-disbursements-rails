# frozen_string_literal: true

module PaymentsContext
  module Disbursements
    module ValueObjects
      class DisbursementReferenceValueObject < SharedContext::ValueObjects::StringValueObject
        value_type Types::Strict::String.constrained(size: 12)
      end
    end
  end
end
