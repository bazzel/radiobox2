class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.integer :song_id
      t.integer :channel
      t.string :title
      t.string :artist
      t.datetime :stopdatetime

      t.timestamps
    end
  end
end
