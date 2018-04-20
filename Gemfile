source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'selenium-webdriver'
  gem 'simplecov', '~> 0.16.1'
  gem 'capybara', '~> 2.18'
  gem 'capybara-webkit', '~> 1.15'
  gem 'capybara-screenshot', '~> 1.0', '>= 1.0.18'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.2'
  gem 'database_cleaner', '~> 1.6', '>= 1.6.2' 
  gem 'factory_bot', '~> 4.8', '>= 4.8.2'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise', '~> 4.4', '>= 4.4.3'
gem 'simple_enum', '~> 2.3', '>= 2.3.1'
gem 'pundit', '~> 1.1'
gem 'jquery-rails', '~> 4.3', '>= 4.3.1'
gem 'simple_form', '~> 3.5', '>= 3.5.1'
gem 'elasticsearch', '~> 6.0', '>= 6.0.2'
gem 'rspec', '~> 3.7'
gem 'faker', '~> 1.8', '>= 1.8.7'
gem 'redis', '~> 4.0', '>= 4.0.1'
gem 'haml', '~> 5.0', '>= 5.0.4'

#Diplom gems

gem 'spree', '~> 3.4.4'
gem 'spree_auth_devise', '~> 3.3'
gem 'spree_gateway', '~> 3.3'
gem 'bootstrap', '~>4.1.0'
gem 'rmagick', '~> 2.16'
gem 'spree_i18n', github: 'spree-contrib/spree_i18n', branch: 'master'
gem 'paperclip'
gem 'spree_digital', github: 'spree-contrib/spree_digital'
gem 'spree_reviews', github: 'spree-contrib/spree_reviews'
gem 'globalize', github: 'globalize/globalize'
gem 'spree_globalize', github: 'spree-contrib/spree_globalize', branch: 'master'
gem 'spree_static_content', github: 'spree-contrib/spree_static_content'
gem 'spree_slider', github: 'spree-contrib/spree_slider'
