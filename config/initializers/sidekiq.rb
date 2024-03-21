# frozen_string_literal: true

# FIXME: move url to env variable or similar

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://:secret@redis:6379/0" }
end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://:secret@redis:6379/0" }
end
