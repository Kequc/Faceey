class AccountsController < ApplicationController
  respond_to :html
  
  def new
    @account = Account.new
    @account.build_profile
    respond_with(@account)
  end
  
  def create
    # Send invitation to user
    # Signup step 1
    @account = Account.new(pass_params(:account, [:email, :password, :password_confirmation, :profile_attributes]))
    if @account.save
      login_profile!(@account)
    else
      render :action => :new
    end
  end
  
  def confirm
    # Confirm email address code
    # Signup step 2
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
