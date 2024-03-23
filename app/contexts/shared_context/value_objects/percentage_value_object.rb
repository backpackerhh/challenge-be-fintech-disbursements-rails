# frozen_string_literal: true

module SharedContext
  module ValueObjects
    class PercentageValueObject < BaseValueObject
      value_type Types::Params::Decimal.constrained(gteq: 0.0, lteq: 100.0)
    end
  end
end
