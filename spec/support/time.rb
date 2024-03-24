# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.around do |example|
    if (time = example.metadata[:freeze_time])
      travel_to(time) { example.run }
    else
      example.run
    end
  end
end
