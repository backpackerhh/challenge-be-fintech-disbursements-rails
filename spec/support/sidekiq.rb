# frozen_string_literal: true

require "sidekiq/testing"

RSpec.configure do |config|
  config.around do |example|
    if example.metadata[:sidekiq_inline]
      Sidekiq::Testing.inline! { example.run }
    else
      example.run
    end
  end
end
