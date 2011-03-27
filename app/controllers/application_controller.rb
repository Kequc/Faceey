class ApplicationController < ActionController::Base
  rescue_from ActionController::RedirectBackError do |exception|
    redirect_to root_path
  end
  before_filter :put_current_profile_into_model

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout 'application'

  helper_method :current_profile, :current_profile_id, :current_profile_id?, :signed_in?, :current_profile_confirmed?, :can_modify?
  helper_method :friend_id?, :friended_id?, :blocked_id?, :hidden_id?

  protected
  
  def current_profile
    return nil unless signed_in?
    unless @current_profile ||= Profile.where(:_id => session[:profile_id]).first
      logout_profile
    end
    @current_profile
  end
  
  def current_profile_id
    session[:profile_id]
  end
  
  def signed_in?
    current_profile_id != nil
  end
  
  def current_profile_confirmed?
    session[:account_confirmed] || false
  end
  
  def current_profile_id?(id)
    signed_in? and id == current_profile_id
  end
  
  def can_modify?(object)
    return false unless signed_in?
    current_profile.can_modify?(object)
  end
  
  def authenticate_profile!
    kick_off_page! unless signed_in?
  end

  def profile_is_owner!(object)
    kick_off_page! unless can_modify?(object)
  end
  
  def profile_is_not_blocked!(object)
    kick_off_page!(nil, relationship_path(object.shared_by_id)) if blocked_id?(object.shared_by_id)
  end

  def friend_id?(id)
    return false unless signed_in?
    current_profile.friend_relationship_ids.include?(id)
  end

  def friended_id?(id)
    return false unless signed_in?
    current_profile.friended_relationship_ids.include?(id)
  end

  def blocked_id?(id)
    return false unless signed_in?
    current_profile.blocked_relationship_ids.include?(id)
  end

  def hidden_id?(id)
    return false unless signed_in?
    current_profile.hidden_relationship_ids.include?(id)
  end

  def kick_off_page!(msg="You don't have permission to do that.", location=:back)
    redirect_to location, :notice => msg
  end
  
  def put_current_profile_into_model
    Profile.current = current_profile
  end

  def login_profile!(account)
    session[:account_confirmed] = account.confirmed
    session[:profile_id] = account.profile._id
    redirect_to profile_path(account.profile)
  end
  
  def logout_profile
    session[:account_confirmed] = nil
    session[:profile_id] = nil
  end
  
  def pass_params(symbol, arr=[])
    return nil unless params[symbol]
    params[symbol].reject{ |k| arr.include?(k) }
  end

  def find_parent_obj
    parent_model = nil
    parent_id = nil
    params.each do |name, value|
      if name =~ /(.+)_id$/
        parent_model = $1.classify.constantize
        parent_id = value
      end
    end
    return parent_model.find(parent_id)
  end
end
