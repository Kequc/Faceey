ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 1025,
  :domain => APP[:site_domain]
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
