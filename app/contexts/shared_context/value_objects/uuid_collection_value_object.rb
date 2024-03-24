# frozen_string_literal: true

module SharedContext
  module ValueObjects
    class UuidCollectionValueObject < BaseValueObject
      value_type Types::Coercible::Array.of(Types::Strict::String.constrained(uuid_v4: true))
    end
  end
end
