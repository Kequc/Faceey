class ProfilesController < ApplicationController
  before_filter :authenticate_profile!, :except => [:index, :show, :new, :create]
  before_filter :find_account, :only => [:new, :create]
  before_filter :find_profile, :only => [:show, :edit, :update, :about]
  before_filter :redirect_if_blocked!, :only => [:show, :about]
  before_filter :find_current_profile, :only => [:close_account]
  
  respond_to :html
  
  def show
    @splashes = Splash.from_stream(@profile).exclude_blocked
    respond_with(@profile)
  end
  
  def new
    @profile = Profile.new
    respond_with(@profile)
  end

  def create
    @profile = Profile.new(pass_params(:profile, [:first_name, :last_name, :terms_of_service]))
    @profile.account = @account
    if @profile.save
      login_profile!(@profile)
    else
      render :action => :new
    end
  end

  def edit
    respond_with(@profile)
  end
  
  def update
    @profile.update_attributes(pass_params(:profile, [:first_name, :last_name, :gender, :birthday, :description, :blurb]))
    respond_with(@profile, :location => about_profile_path(@profile))
  end
  
  def about
    respond_with(@profile)
  end
  
  def close_account
    respond_with(@profile)
  end
  
  def account_details
    @profile.update_attributes(params[:profile])
    respond_with(@profile, :location => profile_path(@profile))
  end
  
  protected

  def find_account
    @account = Account.find(params[:account_id])
    # Redirect if profile already exists or password not set
    redirect_through_profile_verification(@account) if !@account.password_hash or @account.profile
  end
  
  def find_profile
    @profile = Profile.find(params[:id])
  end
  
  def redirect_if_blocked!
    profile_is_not_blocked!(@profile)
  end
  
  def find_current_profile
    @profile = current_profile
  end
end
