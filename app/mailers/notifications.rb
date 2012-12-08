class Notifications < ActionMailer::Base
  default from: "briandquinn@gmail.com"

  def error_rate_increase(app)
    subject = "'#{app['name']}' error rates increasing"

    app['notify'].each do |email|
      mail to: email, subject: subject
    end
  end

  def no_contact(app)
    subject = "'#{app['name']}' is out of contact"

    app['notify'].each do |email|
      mail to: email, subject: subject
    end
  end
end
