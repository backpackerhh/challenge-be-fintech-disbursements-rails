# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.around do |example|
    if example.metadata[:freeze_time]
      freeze_time { example.run }
    else
      example.run
    end
  end
end
