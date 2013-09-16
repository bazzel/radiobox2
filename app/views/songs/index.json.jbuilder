json.array!(@songs) do |song|
  json.extract! song, :title, :artist
  json.url song_url(song, format: :json)
end
