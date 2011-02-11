class AccountMailer < ActionMailer::Base
  default :from => "Account assistant <accounts@#{APP[:site_domain]}>"
  
  def welcome_email(account)
    @account = account
    mail(:to => @account.email_to_string(account.new_email), :subject => "Hello from #{APP[:site_name]}!")
  end
  
  def password(account)
    @account = account
    mail(:to => @account.email_to_string, :subject => "Password reset request")
  end
end
