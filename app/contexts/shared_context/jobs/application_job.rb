# frozen_string_literal: true

module SharedContext
  module Jobs
    class ApplicationJob < ActiveJob::Base
      sidekiq_options unique: true, retry_for: 3600 # 1 hour
    end
  end
end
