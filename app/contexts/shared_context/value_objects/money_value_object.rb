# frozen_string_literal: true

module SharedContext
  module ValueObjects
    class MoneyValueObject < BaseValueObject
      value_type Types.Constructor(Money) { |value|
                   amount = value.respond_to?(:amount) ? value.amount : value

                   ::Money.from_amount(Types::Params::Decimal[amount])
                 }
    end
  end
end
