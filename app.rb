#require 'bundler'
#Bundler.require

require 'sinatra'
require 'json'
require 'data_mapper'
require 'unicorn'
require 'dm-postgres-adapter'


# Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
# set, when working locally this line will fall back to using SQLite in the
# current directory.
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

# Define a simple DataMapper model.
class Song
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :created_at, DateTime
  property :title, String, :length => 255
  #property :description, Text
end

# Finalize the DataMapper models.
DataMapper.finalize

# Tell DataMapper to update the database according to the definitions above.
DataMapper.auto_upgrade!

get '/' do
  send_file './public/index.html'
end

# Route to show all Songs, ordered like a blog
get '/songs' do
  content_type :json
  @songs = Song.all(:order => :created_at.desc)

  @songs.to_json
end

# CREATE: Route to create a new Song
post '/songs' do
  content_type :json

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  #params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.
  @song = Song.new(params)

  if @song.save
    @song.to_json
  else
    halt 500
  end
end

# READ: Route to show a specific Song based on its `id`
get '/songs/:id' do
  content_type :json
  @song = Song.get(params[:id].to_i)

  if @song
    @song.to_json
  else
    halt 404, { :error => "404" }.to_json
    
  end
end

get '/songs/:title' do
  content_type :json
  @song = Song.get(params[:title].to_s)

  if @song
    @song.to_json
  else
    halt 404
  end
end

# UPDATE: Route to update a Song
put '/songs/:id' do
  content_type :json

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  #params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.

  @song = Song.get(params[:id].to_i)
  @song.update(params)

  if @song.save
    @song.to_json
  else
    halt 500
  end
end

# DELETE: Route to delete a Song
delete '/songs/:id/delete' do
  content_type :json
  @song = Song.get(params[:id].to_i)

  if @song.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end



=begin 
end
# If there are no Songs in the database, add a few.
if Song.count == 0
  Song.create(:title => "Test Song One", :description => "blabalalblalbalal.")
  Song.create(:title => "Test Song Two", :description => "Other blabalalblalbalal.")
end
=end
