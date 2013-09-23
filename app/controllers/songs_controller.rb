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
        response.stream.write "data: #{song.to_json}\n\n"
      end
      #ActiveRecord::Base.connection_pool.release_connection
      ActiveRecord::Base.clear_active_connections!
      sleep duration
    end
  rescue IOError
    logger.error $!
  ensure
    response.stream.close
  end

end
