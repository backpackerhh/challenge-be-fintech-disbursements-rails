# frozen_string_literal: true

module PaymentsContext
  module Orders
    module ValueObjects
      class OrderDisbursementIdValueObject < Disbursements::ValueObjects::DisbursementIdValueObject
        value_type Types::Strict::String.constrained(uuid_v4: true).optional
      end
    end
  end
end
