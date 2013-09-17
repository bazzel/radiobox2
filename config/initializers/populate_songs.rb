begin
  Song.populate
rescue SQLite3::SQLException

end
