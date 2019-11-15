source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'

# group :development, :test do #We should have the same DB for all the environments!
#   # Use sqlite3 as the database for Active Record
#   gem 'sqlite3' #Herokuu doesn't support sqlite3 because it's a development database
# end

#group :production do
# Use PostgreSQL as the database for Active Record
gem 'pg' #sudo apt-get install libpq-dev
#end

# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Active Model Serializers to make custom jsons easily
gem 'active_model_serializers' 

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# This is required because angular requests can present problems...
gem 'rack-cors', '~> 1.0.5' 

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'

gem 'mechanize', '2.7.5'
gem 'watir', '6.10.3'
gem 'selenium-webdriver', '3.9.0'
gem 'webdrivers', '3.2.4'

#For Bundler problems!
# gem uninstall bundler
# gem install bundler -v 2.0.2
# bundle update

#For Heroku problems with chromedriver!

# heroku buildpacks:clear --app=unimatrix-api 

# heroku buildpacks:add --app=unimatrix-api heroku/google-chrome
# heroku buildpacks:add --app=unimatrix-api heroku/chromedriver

# heroku config:set --app=unimatrix-api CHROMEDRIVER_VERSION=2.35.528139
# heroku config:set --app=unimatrix-api WD_CHROME_PATH=/app/.apt/usr/bin/google-chrome

# heroku buildpacks:add --app=unimatrix-api https://github.com/dwayhs/heroku-buildpack-chrome
# heroku buildpacks:add --app=unimatrix-api https://github.com/heroku/heroku-buildpack-chromedriver
# heroku buildpacks:add --app=unimatrix-api heroku/ruby

#For Heroku ENV
# heroku config:set --app=unimatrix-api chromedriver=/app/.chromedriver/bin/chromedriver