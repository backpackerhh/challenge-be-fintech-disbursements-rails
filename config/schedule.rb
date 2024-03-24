# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Learn more: http://github.com/javan/whenever

set :output, { error: "#{path}/log/cron.error.log", standard: "#{path}/log/cron.log" }

every 1.day, at: "07:00 am" do
  rake "payments_context:disbursements:generate"
end
