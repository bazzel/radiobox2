begin
  Song.populate (1..6)
rescue #SQLite3::SQLException
  puts $!
end
