require 'open-uri'

class Song
  attr_accessor :channel, :title, :artist

  class << self
    def all
      (1..6).map { |channel| currently_on(channel)}
    end

    private
    def currently_on(channel)
      enc_uri = URI.escape("http://radiobox2.omroep.nl/track/search.json?q=channel.id:'%s'+AND+startdatetime<NOW+AND+stopdatetime>NOW" % channel)

      open(enc_uri) do |f|
        json = JSON.parse(f.read)
        result = json["results"].first
        songfile = result["songfile"]

        new.tap do |song|
          song.channel = result["channel"]
          song.artist = songfile["artist"]
          song.title = songfile["title"]
        end
      end

    end
  end
end
