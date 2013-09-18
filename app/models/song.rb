require 'open-uri'

class Song < ActiveRecord::Base
  class << self
    def schedule_at
      first_finished.try(:stopdatetime) || 1.minute.from_now
    end

    def first_finished
      where('stopdatetime > ?', Time.now).order('stopdatetime').first
    end

    def refresh
      channels = to_refresh.pluck(:channel)

      transaction do
        channels.each { |channel| currently_on(channel)}
      end
      clear_active_connections!

      Rufus::Scheduler.new.at(schedule_at) { send(__method__.to_sym) }
    end

    def to_refresh
      where('stopdatetime < ?', schedule_at)
    end

    def populate
      transaction do
        (1..6).each { |channel| currently_on(channel)}
      end
      clear_active_connections!
      refresh
    end

    def currently_on(channel)
      enc_uri = URI.escape("http://radiobox2.omroep.nl/track/search.json?q=channel.id:'%s'+AND+startdatetime<NOW+AND+stopdatetime>NOW" % channel)

      open(enc_uri) do |f|
        json = JSON.parse(f.read)
        result = json["results"].first
        songfile = result["songfile"]

        where(channel: channel).first_or_initialize.tap do |song|
          song.channel = result["channel"]
          song.artist = songfile["artist"]
          song.title = songfile["title"]
          song.stopdatetime = result["stopdatetime"]
          song.save
        end
      end

    end
  end
end
