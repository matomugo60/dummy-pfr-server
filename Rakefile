require_relative "./config/environment"

require "sinatra/activerecord/rake"

# desc "Seed the database"
# task :seed do
#   # require_relative "../db/seeds.rb"
#   puts "Seeding complete"
# end
# end

# namespace :db do
#     desc "Migrate the database"
#     task :migrate do
#       ActiveRecord::Migration.verbose = true
#        ActiveRecord::Migrator.migrate("db/migrate")
#       puts "Migration complete"
#     end

desc "Start the server"
task :server do  
  if ActiveRecord::Base.connection.migration_context.needs_migration?
    puts "Migrations are pending. Make sure to run `rake db:migrate` first."
    return
  end

  ENV["PORT"] ||= "9292"
  rackup = "rackup -p #{ENV['PORT']}"

  exec "bundle exec rerun -b '#{rackup}'"
end

desc "Start the console"
task :console do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  Pry.start
end