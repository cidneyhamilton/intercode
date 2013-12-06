source 'http://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

platform :ruby do
  gem 'sqlite3', :groups => [:development, :test]
  gem 'pg', :group => :production
  gem 'puma'
end

platform :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcsqlite3-adapter', :groups => [:development, :test]
  gem 'activerecord-jdbcpostgresql-adapter', :group => :production
  gem 'mizuno'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
  
  # Upload assets to Amazon S3 during compilation phase
  gem 'asset_sync'
end

gem 'jquery-rails'

# Devise for authentication, authority for authorization
gem 'devise'
gem 'authority'

# Lightweight open-source CMS (written by Nat for Gively Inc.)
gem 'cadmus'

# File uploading
gem 'carrierwave'

gem 'puma'
gem 'pry-rails', :groups => [:development, :test]

group :development, :test do
  gem 'pry-rails'
  gem 'pry-remote'
end

# Fixture replacement for test suite
group :development, :test do
  gem 'factory_girl', '~> 2.6'
  gem 'factory_girl_rails'
end
