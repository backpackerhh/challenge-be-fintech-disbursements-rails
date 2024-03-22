# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantLiveOnValueObjectFactory
        def self.build(value = Date.yesterday)
          value
        end
      end
    end
  end
end
