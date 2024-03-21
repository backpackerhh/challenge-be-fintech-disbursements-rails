# frozen_string_literal: true

module SharedContext
  module ValueObjects
    class UuidValueObject < BaseValueObject
      value_type Types::Strict::String.constrained(uuid_v4: true)
    end
  end
end
