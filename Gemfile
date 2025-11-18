source 'https://rubygems.org'

ruby '3.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2.0'

# Required for Ruby 3.3 compatibility
gem 'logger'
gem 'ostruct'
gem 'mutex_m'
gem 'base64'
gem 'bigdecimal'
gem 'matrix'
gem 'drb'

# Use Postgres as the database for Active Record
gem 'pg'

# Use Puma as the web server
gem 'puma', '~> 6.0'

# Use SCSS for stylesheets
gem 'sassc'
gem 'sass-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Use ActiveModel has_secure_password
gem 'bcrypt'

# For exporting pdf file
gem 'prawn'
gem 'prawn-table'

# For backups, generate seeds.rb file
gem 'seed_dump'

# For soft delete
gem 'paranoia', '~> 3.0'

# For tracking changes to the models, for auditing or versioning
# https://github.com/paper-trail-gem/paper_trail
gem "paper_trail", "~> 15.0"

# For command line prompt
gem "tty-prompt"

# Use to serialize json response payload
gem "active_model_serializers"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# Use for searching
gem 'ransack', '~> 4.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Use for adding annotations to the models
  # https://github.com/ctran/annotate_models
  gem 'annotate'
end

gem "pundit", "~> 2.3"
