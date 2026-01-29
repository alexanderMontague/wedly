source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "bcrypt", "~> 3.1.7"
gem "bootsnap", require: false
gem "importmap-rails"
gem "jbuilder"
gem "mysql2", "~> 0.5"
gem "propshaft"
gem "puma", "~> 6.0"
gem "rails", "~> 7.1.0"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "faker"
end

group :development do
  gem "foreman"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
