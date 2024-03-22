# frozen_string_literal: true

module PaymentsContext
  module Orders
    module ValueObjects
      class OrderReferenceValueObject < SharedContext::ValueObjects::StringValueObject
        value_type Types::Strict::String.constrained(size: 12)
      end
    end
  end
end
