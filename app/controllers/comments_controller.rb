class CommentsController < ApplicationController
  before_filter :authenticate_profile!
  before_filter :find_parent, :only => [:new, :create]
  before_filter :redirect_if_blocked!, :only => [:new, :create]
  before_filter :find_comment, :only => [:destroy]
  before_filter :profile_is_comment_owner!, :only => [:destroy]

  respond_to :html
  
  def new
  end

  def create
    @comment = Comment.new(pass_params(:comment, [:content, :link_submitted]))
    @parent.comments << @comment
    respond_with(@comment, :location => polymorphic_path(@parent, :comment_id => @comment._id))
  end
  
  def destroy
    @comment.destroy
    respond_with(@comment, :location => @comment.item)
  end
  
  protected
  def find_comment
    @comment = Comment.find(params[:id])
  end
  
  def find_parent
    @parent = find_parent_obj
  end

  def profile_is_comment_owner!
    profile_is_owner!(@comment)
  end
  
  def redirect_if_blocked!
    profile_is_not_blocked!(@parent)
  end
end
