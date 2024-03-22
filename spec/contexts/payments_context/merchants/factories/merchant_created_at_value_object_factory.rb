# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantCreatedAtValueObjectFactory
        def self.build(value = Time.current)
          value
        end
      end
    end
  end
end
