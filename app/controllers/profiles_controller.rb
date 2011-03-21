class ProfilesController < ApplicationController
  before_filter :authenticate_profile!, :except => [:index, :show]
  before_filter :find_profile, :only => [:show, :edit, :update, :about]
  before_filter :redirect_if_blocked!, :only => [:show, :about]
  
  respond_to :html
  
  def show
    @splashes = Splash.from_stream(@profile).exclude_blocked
    respond_with(@profile)
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
    @profile = current_profile
    respond_with(@profile)
  end
  
  def account_details
    @profile.update_attributes(params[:profile])
    respond_with(@profile, :location => profile_path(@profile))
  end
  
  protected
  
  def find_profile
    @profile = Profile.find(params[:id])
  end
  
  def redirect_if_blocked!
    profile_is_not_blocked!(@profile)
  end
end
