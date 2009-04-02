require Rails.root.join("config", "environment")

if KVC::Settings.table_exists?
  print "Also drop the KVC table? [Yn] "
  if STDIN.gets.chomp =~ /^(?:\s*$|y)/i
    ActiveRecord::Base.connection.drop_table :kvc_settings
    puts "Successfully dropped KVC::Settings."
  end
end
