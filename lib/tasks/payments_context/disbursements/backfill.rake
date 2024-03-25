# frozen_string_literal: true

namespace :payments_context do
  namespace :disbursements do
    desc "[OTT] Start process to backfill disbursements (and monthly fees) for all merchants"
    task backfill: [:environment] do
      merchants = PaymentsContext::Merchants::Repositories::PostgresMerchantRepository.all

      merchants.each do |merchant|
        PaymentsContext::Orders::Jobs::GroupDisbursableOrdersJob.perform_async(
          merchant.disbursement_frequency.value.downcase,
          merchant.id.value
        )
      end

      Rails.logger.info("Job enqueued to backfill disbursements for all merchants")
    rescue StandardError => e
      Rails.logger.error("Job enqueued to backfill disbursements for all merchants failed: #{e.inspect}")

      puts e.inspect
      puts "Example usage: rake payments_context:disbursements:backfill"
    end
  end
end
