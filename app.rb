require 'bundler'
Bundler.require


configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.sqlite")
end

configure :production do
    DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_RED_URL'])
end

# Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
# set, when working locally this line will fall back to using SQLite in the
# current directory.
#DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

# Define a simple DataMapper model.
class Song
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :like, Integer, :default => 0
  property :created_at, DateTime
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
  @songs = Song.all(:order => :likes.desc)
  @songs.to_json
end

# CREATE: Route to create a new Song
post '/songs' do
  content_type :json  
  #params_json = JSON.parse(request.body.read)
 
  @song = Song.first_or_create(params)

  @song.like = @song.like.next #Incrementing the number of likes by one.

  if @song.save
    @song.to_json
  else
    halt 500, { :error => "500" }.to_json
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




get '/title/:title' do
  content_type :json
    
  @song = Song.first(:title => params[:title].to_s)

  if @song
    @song.to_json
  else
    halt 404, { :error => "do not work with title(" }.to_json
  end
end








# Route to show 5 Top Songs based on amount of their likes
get '/getTop' do
  content_type :json

  @topsongs = Song.all(:limit => 5, :order => [:likes.desc])

  if @topsongs
    @topsongs.to_json
  else
    halt 404, {:error => "no top 404"}.to_json
  end
end






# UPDATE: Route to update a Song
put '/songs/:id' do
  content_type :json

  @song = Song.get(params[:id].to_i)
  @song.title = (params[:title])
  @song.likes = (params[:likes])
  @song.save

  if @song.save
    @song.to_json
  else
    halt 500, { :error => "500" }.to_json
  end
end






# DELETE: Route to delete a Song
delete '/songs/:id/delete' do
  content_type :json
  @song = Song.get(params[:id].to_i)

  if @song.destroy
    {:success => "ok"}.to_json
  else
    halt 500, { :error => "500" }.to_json
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
