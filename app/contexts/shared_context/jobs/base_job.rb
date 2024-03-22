# frozen_string_literal: true

require "sidekiq"

module SharedContext
  module Jobs
    class BaseJob
      def self.inherited(base)
        super
        base.include(Sidekiq::Job)
        base.sidekiq_options unique: true, retry_for: 3600 # 1 hour
      end
    end
  end
end
