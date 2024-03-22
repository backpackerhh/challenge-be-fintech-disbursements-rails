# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantIdValueObjectFactory
        def self.build(value = SecureRandom.uuid)
          value
        end
      end
    end
  end
end
