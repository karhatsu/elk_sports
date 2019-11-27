source 'http://rubygems.org'
ruby '2.6.5'

gem 'rails', '6.0.1'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-ui-themes'
gem 'sassc-rails'
gem 'authlogic'
gem 'wicked_pdf'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'coffee-rails'
gem 'uglifier'
gem 'activerecord-session_store'
gem 'haml-rails'
gem 'rack-mini-profiler'
gem 'dalli'
gem 'roman-numerals'
gem 'nokogiri'
gem 'redcarpet'
gem 'kaminari'

group :development, :production do
  gem 'pg'
  gem 'unicorn'
end

group :production do
  gem 'rails_12factor'
  gem 'newrelic_rpm'
  gem 'exception_notification'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'minitest'
  gem 'capybara'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'email_spec'
  gem "factory_bot_rails", :require => false
  gem 'launchy'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'
  gem 'fuubar'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'gherkin'
  gem 'ruby-prof'
  gem 'therubyracer'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
end
