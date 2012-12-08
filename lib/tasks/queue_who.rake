task :monitor => :environment do
  QueueWho::Monitor.new
end
