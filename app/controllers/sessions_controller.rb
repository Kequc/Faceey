class SessionsController < ApplicationController
  def new
  end
  
  def create
    s = params[:session]
    account = Account.authenticate(s[:email], s[:password]) if s
    if account
      login_profile!(account)
    else
      redirect_to new_session_path, :notice => "Unsuccessful login"
    end
  end
  
  def destroy
    if session[:profile_id]
      logout_profile
      redirect_to new_session_path
    end
  end
end
