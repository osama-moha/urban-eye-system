source "https://rubygems.org"

# Rails 8 Core
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "jbuilder"

# AUTHENTICATION
gem "devise"

# DATABASE SETUP (The "Split Brain")
# 1. Use SQLite on your Laptop (Development)
group :development, :test do
  gem "sqlite3", ">= 2.1"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "web-console"
end

# 2. Use PostgreSQL on the Internet (Production)
group :production do
  gem "pg", "~> 1.1"
end

# UTILITIES
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

# ADMIN & EXCEL
gem "administrate"
gem "caxlsx_rails"

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end