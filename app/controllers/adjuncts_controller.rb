class AdjunctsController < ApplicationController
  before_filter :authenticate_profile!
  before_filter :find_current_profile
  
  respond_to :html
  
  def index
    @adjuncts = @profile.adjuncts.not_blocked
    respond_with(@profile)
  end
  
  def destroy
    respond_with(@profile)
  end

  protected
  
  def find_current_profile
    @profile = current_profile
  end
end
