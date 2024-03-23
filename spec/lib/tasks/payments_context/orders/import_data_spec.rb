# frozen_string_literal: true

require "rails_helper"

RSpec.describe "payments_context:orders:import_data", type: %i[task database] do
  include_context "rake"

  it "preloads the environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "aborts execution when no file path is given" do
    expect { task.invoke }.to output(/No file path given.+Example usage/m).to_stdout
  end

  it "aborts execution when given file does not exist" do
    expect { task.invoke("spec/support/data/fake.csv") }.to output(/not found.+Example usage/m).to_stdout
  end

  it "imports orders from given file", :sidekiq_inline do
    order_repository = PaymentsContext::Orders::Repositories::PostgresOrderRepository.new

    PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "padberg_group")
    PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "deckow_gibson")
    PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "romaguera_and_sons")

    expect do
      task.invoke("spec/support/data/orders.csv")
    end.to(change { order_repository.size }.from(0).to(6))
  end

  # FIXME: remove this example if domain event is used instead of a job from another module
  it "generates order commissions for each order created", :sidekiq_inline do
    order_commission_repository = PaymentsContext::OrderCommissions::Repositories::PostgresOrderCommissionRepository.new

    PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "padberg_group")
    PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "deckow_gibson")
    PaymentsContext::Merchants::Factories::MerchantEntityFactory.create(reference: "romaguera_and_sons")

    expect do
      task.invoke("spec/support/data/orders.csv")
    end.to(change { order_commission_repository.size }.from(0).to(6))
  end
end
