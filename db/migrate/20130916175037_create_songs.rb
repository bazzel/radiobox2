class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :channel
      t.string :title
      t.string :artist

      t.timestamps
    end
  end
end
