class AccountsController < ApplicationController
  respond_to :html
  
  def new
    @account = Account.new
    @profile = Profile.new
    respond_with(@account)
  end
  
  def create
    @account = Account.new(pass_params(:account, [:email, :password, :password_confirmation]))
    @profile = Profile.new(pass_params(:profile, [:first_name, :last_name, :terms_of_service]))
    @account.profile = @profile
    if @account.save
      login_profile!(@account)
    else
      render :action => :new
    end
  end
  
  def confirm
    @account = Account.find(params[:id])
    if @account.email_code and @account.new_email and @account.email_code == params[:email_code]
      @account.update_attributes(:email => @account.new_email, :confirmed => true, :new_email => nil, :email_code => nil)
      flash[:notice] = "Email address confirmed"
      AccountMailer.welcome(@account).deliver
    else
      flash[:notice] = "Code invalid please retry"
    end
    redirect_to signed_in? ? profile_path(current_profile) : new_session_path
  end
  
  def terms_of_service
  end
end
