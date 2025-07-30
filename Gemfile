source "https://rubygems.org"
ruby "3.4.5"

gem "rails", "~> 8.0.2"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "rubocop", "~> 1.77", require: false
  gem "rubocop-rails", "~> 2.32", require: false
  gem "rubocop-rspec", "~> 3.6.0", require: false
  gem "rubocop-performance", "~> 1.25.0", require: false
  gem "rubocop-rails-omakase", "~> 1.1.0", require: false
end

group :test do
  gem "vcr"
  gem "webmock"
  gem "shoulda-matchers"
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 8.0", require: false
  gem 'database_cleaner-active_record'
  gem 'faker'
end
