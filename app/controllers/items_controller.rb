class ItemsController < ApplicationController
  before_filter :authenticate_profile!, :only => [:new, :create, :destroy]
  before_filter :find_item, :only => [:show, :destroy]
  before_filter :find_stream, :only => [:new, :create]
  before_filter :profile_is_item_owner!, :only => [:destroy]

  respond_to :html

  def show
    profile_is_not_blocked!(@item)
    @stream = @item.stream
    @item.clear_adjuncts
    respond_with(@item) do |format|
      format.html { render "#{@item._type.tableize}/show" }
    end
  end
  
  def new
  end

  def create
    if params[:item][:attach] or params[:item][:remote_attach_url]
      @item = Picture.new(pass_params(:item, [:content, :attach, :remote_attach_url]))
    else
      @item = Thought.new(pass_params(:item, [:content, :link_submitted]))
    end
    @item.stream = @stream
    @item.save
    respond_with(@item, :location => @stream)
  end
  
  def destroy
    @item.destroy
    respond_with(@item, :location => @item.stream)
  end
  
  protected

  def find_item
    @item = Item.find(params[:id])
  end
  
  def find_stream
    @stream = Stream.find(params[:stream_id])
  end
  
  def profile_is_item_owner!
    profile_is_owner!(@item)
  end
end
