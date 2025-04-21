source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.6'  # Use your Ruby version

# Core Rails gems
gem 'rails', '~> 7.1.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 6.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false

# Authentication
gem 'devise'

# PDF Generation
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Excel Export
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'money', '~> 6.16'  # Core Money gem
gem 'monetize'
# Money and Currency Handling
gem 'money-rails'

# UI Components
gem 'bootstrap', '~> 5.3.5'
gem 'jquery-rails'
gem 'font-awesome-rails'

# Charts and Visualization
gem 'gon'  # For passing data to JavaScript
gem 'logger'
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
  gem 'shoulda-matchers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
