# frozen_string_literal: true

namespace :payments_context do
  namespace :disbursements do
    desc "Start process to generate disbursements (and monthly fees)"
    task generate: [:environment] do
      PaymentsContext::Disbursements::Jobs::GenerateDisbursementsJob.perform_async

      Rails.logger.info("Job enqueued to generate disbursements")
    rescue StandardError => e
      Rails.logger.error("Job enqueued to generate disbursements failed: #{e.inspect}")

      puts e.inspect
      puts "Example usage: rake payments_context:disbursements:generate"
    end
  end
end
