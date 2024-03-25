# frozen_string_literal: true

require "smarter_csv"

module PaymentsContext
  module Merchants
    module Jobs
      class ImportMerchantsJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "import_data"

        def perform(file_path)
          raw_merchants = SmarterCSV.process(file_path, headers_in_file: true, col_sep: ";")

          raw_merchants.each_with_index do |raw_merchant, idx|
            delay = idx * 2 # in seconds

            CreateMerchantJob.perform_in(delay, raw_merchant.transform_keys(&:to_s))

            logger.info("Job enqueued to create merchant #{raw_merchant[:id]}")
          end
        rescue StandardError => e # FIXME: decide what exception/s should be rescued here and what to do with them
          logger.error("Found error processing given file (#{file_path}): #{e.message}")
        end
      end
    end
  end
end
