# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::Orders::Jobs::ImportOrdersJob, type: :job do
  it "has expected configuration" do
    expect(described_class.sidekiq_options.transform_keys(&:to_sym)).to eq(
      {
        queue: "import_data",
        unique: true,
        retry: true,
        retry_for: 3600
      }
    )
  end
end
