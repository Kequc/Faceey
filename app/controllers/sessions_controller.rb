class SessionsController < ApplicationController
  def new
  end
  
  def create
    s = params[:session]
    account = Account.authenticate(s[:email], s[:password]) if s
    if account
      redirect_through_profile_verification(account)
    else
      redirect_to login_path, :notice => "Unsuccessful login"
    end
  end
  
  def destroy
    if session[:profile_id]
      session[:profile_id] = nil
      redirect_to login_path
    end
  end
end
