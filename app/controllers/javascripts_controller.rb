class JavascriptsController < ApplicationController
  caches_page :constants

  def constants
    render :template => 'layouts/constants.js.erb', :layout => false
  end
end
