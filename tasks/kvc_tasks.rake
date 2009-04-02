namespace :kvc do
  desc "Drop the KVC::Settings table"
  task :drop_table do
    if KVC::Settings.table_exists?
      ActiveRecord::Base.connection.drop_table :kvc_settings
    end
  end
end
