# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "7.1.3.2"

# Databases
gem "pg", "~> 1.1"

# Background jobs
gem "sidekiq", "~> 7.2"

# Cron
gem "whenever", "~> 1.0", require: false

# CSV
gem "smarter_csv", "~> 1.10"

# Clean Ruby
gem "dry-struct", "~> 1.6"
gem "dry-types", "~> 1.7"

# Money
gem "money-rails", "~> 1.12"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails", "~> 6.4.3"
  gem "faker", "~> 3.2.3"
  gem "rspec-rails", "~> 6.1.0"
  gem "rubocop", "~> 1.60", require: false
  gem "rubocop-performance", "~> 1.20", require: false
  gem "rubocop-rails", "~> 2.23", require: false
  gem "rubocop-rspec", "~> 2.26", require: false
end

group :test do
  gem "database_cleaner-active_record", "~> 2.1"
end
