source 'https://rubygems.org'
ruby '2.2.3'

gem 'sinatra'
gem 'json'
gem 'data_mapper'
gem 'passenger'
gem 'shotgun'

# When developing an app locally you can use mysql which is a relational
# database stored in a file. It's easy to set up and just fine for most
# development situations.

group :development do
  gem 'dm-mysql-adapter'
  gem 'do_mysql'
end

# Heroku uses Postgres however, so we tell the Gemfile to use Postgres
# in production instead of mysql.
group :production do
  gem 'dm-postgres-adapter'
  gem 'pg'
end
