# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentsContext::Merchants::Jobs::ImportMerchantsJob, type: :job do
  it "is executed in expected queue" do
    expect(described_class.queue_name).to eq("import_data")
  end

  it "has expected configuration" do
    expect(described_class.sidekiq_options.transform_keys(&:to_sym)).to match(
      hash_including(
        unique: true,
        retry: true,
        retry_for: 3600
      )
    )
  end
end
