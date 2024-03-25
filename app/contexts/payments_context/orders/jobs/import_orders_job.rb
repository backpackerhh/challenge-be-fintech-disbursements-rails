# frozen_string_literal: true

require "smarter_csv"

module PaymentsContext
  module Orders
    module Jobs
      class ImportOrdersJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "import_data"

        attr_reader :merchants_finder_service

        def initialize(merchants_finder_service: Merchants::Services::FindAllMerchantsService.new)
          super()
          @merchants_finder_service = merchants_finder_service
        end

        def perform(file_path)
          options = {
            chunk_size: Rails.configuration.x.payments_context.import_orders_chunk_size,
            headers_in_file: true,
            col_sep: ";"
          }

          SmarterCSV.process(file_path, options) do |chunk|
            chunk.each do |raw_order|
              raw_order.transform_keys!(&:to_s)
              raw_order["reference"] = raw_order["id"]
              raw_order["id"] = SecureRandom.uuid
              raw_order["merchant_id"] = merchants_dictionary[raw_order["merchant_reference"]]
            end

            Sidekiq::Client.push_bulk("class" => CreateOrderJob, "args" => chunk.zip)

            logger.info("Jobs enqueued to create orders")
          end
        rescue StandardError => e # FIXME: decide what exception/s should be rescued here and what to do with them
          logger.error("Found error processing given file (#{file_path}): #{e.message}")
        end

        private

        def merchants_dictionary
          @merchants_dictionary ||= begin
            merchants = merchants_finder_service.find_all

            merchants.each_with_object({}) do |merchant, dictionary|
              dictionary[merchant.reference.value] = merchant.id.value
            end
          end
        end
      end
    end
  end
end
