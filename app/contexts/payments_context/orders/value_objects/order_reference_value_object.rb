# frozen_string_literal: true

module PaymentsContext
  module Orders
    module ValueObjects
      class OrderReferenceValueObject < SharedContext::ValueObjects::StringValueObject
        # NOTE: The range below tries to successfully handle some references included in the CSV file
        value_type Types::Coercible::String.constrained(size: 9..12)
      end
    end
  end
end
