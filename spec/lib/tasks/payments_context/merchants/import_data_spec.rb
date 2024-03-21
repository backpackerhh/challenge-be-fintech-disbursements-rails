# frozen_string_literal: true

require "rails_helper"

RSpec.describe "payments_context:merchants:import_data", type: %i[task database] do
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

  it "imports merchants from given file", :sidekiq_inline do
    repository = PaymentsContext::Merchants::Repositories::PostgresMerchantRepository.new

    expect do
      task.invoke("spec/support/data/merchants.csv")
    end.to(change { repository.size }).from(0).to(4)
  end
end
