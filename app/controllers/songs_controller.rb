class SongsController < ApplicationController
  include ActionController::Live

  # GET /songs
  # GET /songs.json
  def index
    @songs = Song.all
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    duration = 5

    while true
      Song.where('updated_at > ?', duration.seconds.ago).each do |song|
      #Song.where(channel: (1..6).to_a.sample).each do |song|
        response.stream.write "data: #{song.to_json}\n\n"
      end
      sleep duration
    end
  rescue IOError
    logger.error $!
  ensure
    response.stream.close
  end

end
