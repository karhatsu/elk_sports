source 'http://rubygems.org'
ruby '2.2.2'

gem 'rails', '4.2.4'
gem 'jquery-rails', '2.1.4'
gem 'jquery-ui-rails', '3.0.0'
gem 'jquery-ui-themes'
gem 'sass'
gem 'authlogic', '3.4.4'
gem 'wicked_pdf', '0.9.10'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier'
gem 'activerecord-session_store'
gem 'haml-rails'
gem 'rack-mini-profiler'
gem 'dalli'

group :development, :staging, :production do
  gem 'pg'
  gem 'unicorn'
end

group :staging, :production do
  gem 'rails_12factor'
end

group :production do
  gem 'newrelic_rpm'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'minitest'
  gem 'capybara', '2.2.1'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'email_spec'
  gem "factory_girl_rails", :require => false
  gem 'launchy'
  gem 'poltergeist', '1.6.0'
  gem 'rspec-rails', '3.2.1'
  gem 'rspec-collection_matchers'
  gem 'shoulda-matchers'
  gem 'sqlite3'
  gem 'fuubar', '2.0.0'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'gherkin'
  gem 'ruby-prof'
  gem 'mongrel', '~> 1.2.0.pre'
  gem 'therubyracer', '0.12.0'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
end
