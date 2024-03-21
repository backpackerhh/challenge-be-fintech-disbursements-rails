# frozen_string_literal: true

namespace :payments_context do
  namespace :merchants do
    desc "[OTT] Import merchants from given file path (parameters: FILE_PATH)"
    task :import_data, [:file_path] => [:environment] do |_t, args|
      if args.file_path.nil?
        raise "No file path given"
      end

      if !File.exist?(args.file_path)
        raise "File not found"
      end

      PaymentsContext::Merchants::Jobs::ImportMerchantsJob.perform_later(args.file_path)

      Rails.logger.info("Job enqueued to import merchants from #{args.file_path}")
    rescue StandardError => e
      puts e.inspect
      puts "Example usage: rake payments_context:merchants:import_data[<file_path>]"
    end
  end
end
