ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => APP[:site_domain],
  :user_name            => "mr.kequc",
  :password             => "rct6fuk8",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
