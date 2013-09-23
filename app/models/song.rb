require 'open-uri'

class Song < ActiveRecord::Base
  class << self
    def populate(channels = nil)
      channels ||= (1..6)
      transaction do
        channels.each { |channel| currently_on(channel)}
      end

      delay(run_at: schedule_at).send(__method__.to_sym, to_refresh.pluck(:channel))
    end

    def schedule_at
      first_finished.try(:stopdatetime) || 1.minute.from_now
    end

    # @return [Song] First song to be finished, could be nil
    def first_finished
      where('stopdatetime > ?', Time.now).order('stopdatetime').first
    end

    # @return [Array<Song>]
    def to_refresh
      where('stopdatetime < ?', schedule_at)
    end

    def currently_on(channel)
      enc_uri = URI.escape("http://radiobox2.omroep.nl/track/search.json?q=channel.id:'%s'+AND+startdatetime<NOW+AND+stopdatetime>NOW" % channel)

      open(enc_uri) do |f|
        json = JSON.parse(f.read)
        result = json["results"].first
        songfile = result["songfile"]

        where(channel: channel).first_or_initialize.tap do |song|
          song.song_id = songfile['id']
          song.channel = result['channel']
          song.artist = songfile['artist']
          song.title = songfile['title']
          song.stopdatetime = result['stopdatetime']

          song.song_id_changed? && song.save
        end
      end
    end
  end
end
