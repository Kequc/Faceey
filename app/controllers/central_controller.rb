class CentralController < ApplicationController
  before_filter :authenticate_profile!, :except => [:good_content, :recent]

  respond_to :html

  def good_content
    if signed_in?
      shared_by_ids = current_profile.friend_relationship_ids-current_profile.hidden_relationship_ids-current_profile.blocked_relationship_ids
      @splashes = Splash.any_in(:shared_by_id => shared_by_ids)
      respond_with(@splashes)
    else
      # render :layout => "home", :template => "content/home"
      render :template => "central/home"
    end
  end
  
  def hidden
    shared_by_ids = (current_profile.friend_relationship_ids+current_profile.hidden_relationship_ids).dups-current_profile.blocked_relationship_ids
    @splashes = Splash.any_in(:shared_by_id => shared_by_ids)
    respond_with(@splashes)
  end
  
  def recent
    shared_by_ids = [] unless signed_in?
    shared_by_ids ||= current_profile.hidden_relationship_ids+current_profile.blocked_relationship_ids
    @splashes = Splash.not_in(:shared_by_id => shared_by_ids)
    respond_with(@splashes)
  end
end
