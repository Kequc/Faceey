class RelationshipsController < ApplicationController
  before_filter :authenticate_profile!
  before_filter :find_profile, :except => :blocked
  before_filter :initialize_relationship, :except => [:index, :blocked]
  before_filter :initialize_acquaintance, :only => [:toggle_block, :toggle_friend]
  
  respond_to :html
  
  def index
    @relationships = Profile.any_in(:_id => @profile.friended_relationship_ids-@profile.blocked_relationship_ids).order_by_name
    respond_with(@relationships)
  end
  
  def blocked
    @profile = current_profile
    @relationships = Profile.any_in(:_id => @profile.blocked_relationship_ids).order_by_name
    respond_with(@relationships)
  end
  
  def show
  end
  
  def toggle_block
    was_blocked = @relationship.blocked?
    @relationship.update_attribute(:blocked, (was_blocked ? false : true))
    @acquaintance.update_attribute(:block, (was_blocked ? false : true))
    redirect_to relationship_path(@profile)
  end
  
  def toggle_friend
    was_friended = @relationship.friended?
    @relationship.update_attribute(:friended, (was_friended ? false : true))
    @acquaintance.update_attribute(:friend, (was_friended ? false : true))
    redirect_to relationship_path(@profile)
  end
  
  def toggle_hide
    was_hidden = @relationship.hidden?
    @relationship.update_attribute(:hidden, (was_hidden ? false : true))
    redirect_to (was_hidden ? hidden_path : good_content_path)
  end
  
  protected
  
  def find_profile
    @profile = Profile.find(params[:id])
  end
  
  def initialize_relationship
    @relationship = current_profile.relationships.find_or_create_by(:_id => @profile._id)
  end

  def initialize_acquaintance
    @acquaintance = @profile.relationships.find_or_create_by(:_id => current_profile._id)
  end
end
