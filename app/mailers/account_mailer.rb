class AccountMailer < ActionMailer::Base
  default :from => "#{APP[:site_name]} <inquiries@#{APP[:site_domain]}>"
  
  def email(account)
    @account = account
    mail(:to => account.email_to_string(account.new_email), :subject => "New email address")
  end
  
  def welcome(account)
    @account = account
    mail(:to => account.email_to_string, :subject => "Thank you!")
  end
  
  def password(account)
    @account = account
    mail(:to => account.email_to_string, :subject => "Password request")
  end
end
