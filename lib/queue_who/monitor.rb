module QueueWho
  class Monitor
    def initialize
      %w{INT QUIT HUP TERM}.each do |sig|
        trap(sig) { shutdown }
      end

      @processing = true
      process
    end

    def process
      puts "Starting Monitor"

      while @processing

        App.all.each do |app|
          ln = app['last_notifications'] || {}
          puts ln.inspect

          last_report = app.reports.sort(:created_at => -1).first

          # ensure we've heard from the app within the timeout window
          #
          if last_report && last_report.created_at < Time.now.utc - 2.minutes
            puts 'no_contact'

            if ln['no_contact'].nil? || ln['no_contact'] < (Time.now.utc - 6.hours)
              ln['no_contact'] = Time.now.utc

              Notifications.no_contact(app).deliver
            end
          else
            puts 'contact is the moment where everything happens'
          end

          # check in error count is increasing
          #
          if last_report && (ln['error_rate_increase'].nil? || ln['error_rate_increase']['failing'] < last_report.failing)
            puts "error_rate_increase"

            if ln['error_rate_increase']['notified_at'] < (Time.now.utc - 1.minute)

              ln['error_rate_increase'] ||= {}
              ln['error_rate_increase']['failing'] = last_report.failing
              ln['error_rate_increase']['notified_at'] = Time.now.utc

              Notifications.error_rate_increase(app).deliver
            end

          end

          app['last_notifications'] = ln
          app.save
        end

        sleep 10

      end
    end

    def shutdown
      puts "Shuting down"
      @processing = false
    end
  end
end
