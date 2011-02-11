class AccountsController < ApplicationController
  respond_to :html
  
  def new
    respond_with(@account = Account.new)
  end
  
  def create
    # Send invitation to user
    # Signup step 1
    @account = Account.find_or_initialize_by(:email => params[:email])
    if !@account.persisted? and !@account.save
      flash[:notice] = "Sending failed"
      render :action => :new
    else
      AccountMailer.welcome_email(@account).deliver
      redirect_to sent_account_path(@account)
    end
  end
  
  def confirm
    # Confirm email address code
    # Signup step 2
    @account = Account.find(params[:id])
    redirect_through_profile_verification(@account) if @account.new_email.blank? and !account.has_profile?
    params[:email_code] = params[:account][:email_code] if params[:account]
    if @account.email_code and @account.email_code == params[:email_code]
      @account.update_attributes(:email => @account.new_email, :new_email => nil, :email_code => nil)
      flash[:notice] = "Email address confirmed"
      redirect_through_profile_verification(@account)
    else
      flash[:notice] = "Code invalid please retry" unless params[:email_code].blank?
    end
  end
  
  def sent
  end
  
  def terms_of_service
  end
end
