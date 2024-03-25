# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module ValueObjects
      class MonthlyFeeMonthValueObject < SharedContext::ValueObjects::StringValueObject
        value_type Types::Strict::String.constrained(size: 7, format: /\A\d{4}-\d{2}\z/)
      end
    end
  end
end
