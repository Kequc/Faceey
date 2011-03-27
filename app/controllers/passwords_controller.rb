class PasswordsController < ApplicationController
  before_filter :find_account, :only => [:edit, :update, :sent]
  before_filter :ensure_valid_password_code!, :only => [:edit, :update]

  respond_to :html

  def new
  end
  
  def create
    # Send password reset instructions to user
    unless params[:email].blank?
      if account = Account.where(:email => params[:email]).first
        account.update_attributes(:password_code => Account.generate_code, :password_code_sent_at => Time.now)
        AccountMailer.password(account).deliver
      end
      redirect_to sent_password_path(account)
    else
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @account.update_attributes(pass_params(:account, [:password, :password_confirmation]))
      @account.password_code = nil
      @account.save
      flash[:notice] = "Password set"
      login_profile!(@account)
    else
      render :action => :edit
    end
  end
  
  def sent
  end

  protected
  
  def find_account
    @account = Account.find(params[:id])
  end
  
  def ensure_valid_password_code!
    unless @account.password_code_verifies?(params[:password_code])
      kick_off_page!("Password change failed please retry", new_password_path)
    end
  end
end
