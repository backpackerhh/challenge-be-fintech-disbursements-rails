# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "7.1.3.2"

# Databases
gem "pg", "~> 1.1"

# Background jobs
gem "sidekiq", "~> 7.2"

# CSV
gem "smarter_csv", "~> 1.10"

# Clean Ruby
gem "dry-struct", "~> 1.6"
gem "dry-types", "~> 1.7"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails", "~> 6.1.0"
  gem "rubocop", "~> 1.60", require: false
  gem "rubocop-performance", "~> 1.20", require: false
  gem "rubocop-rails", "~> 2.23", require: false
  gem "rubocop-rspec", "~> 2.26", require: false
end
