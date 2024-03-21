# frozen_string_literal: true

module SharedContext
  module ValueObjects
    class EmailValueObject < BaseValueObject
      value_type Types::Strict::String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
    end
  end
end
