# frozen_string_literal: true

module PaymentsContext
  module Merchants
    module Factories
      class MerchantEmailFactory
        def self.build(value = Faker::Internet.email)
          value
        end
      end
    end
  end
end
