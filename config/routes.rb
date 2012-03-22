Faceey::Application.routes.draw do
  root :to => "central#good_content"
  match "/javascripts/constants.js", :to => 'javascripts#constants'

  resources :profiles, :only => [:show, :edit, :update] do
    # get :all_posts, :on => :member
    get :relationships, :on => :member, :to => 'relationships#index'
    get :about, :on => :member
  end
  # match "/close_account", :to => "profiles#close_account", :via => :get, :as => "close_account"
  resources :adjuncts, :only => [:index, :destroy], :path => "updates"

  scope :via => :get do
    match "good_content", :as => "good_content", :to => 'central#good_content'
    match "hidden", :as => "hidden", :to => 'central#hidden'
    match "recent", :as => "recent", :to => 'central#recent'
  end

  resources :relationships, :only => :show
  resources :relationships, :only => [], :path => "sharing" do
    get :blocked, :on => :collection
    get :toggle_block, :on => :member
    get :toggle_friend, :on => :member
    get :toggle_hide, :on => :member
  end

  resources :streams, :only => [] do
    resources :items, :only => [:new, :create]
  end
  resources :items, :only => :destroy do
    resources :comments, :only => [:new, :create]
  end
  resources :comments, :only => :destroy
  resources :thoughts, :only => :show, :controller => "items"
  resources :pictures, :only => :show, :controller => "items"

  resources :sessions, :only => [:new, :create]
  match "sign_out", :to => "sessions#destroy", :via => :get, :as => "logout"
  resources :passwords, :only => [:new, :create] do
    get :sent, :on => :member
    get :edit, :on => :member, :path => 'change(/:password_code)'
    put :update, :on => :member, :path => 'change(/:password_code)'
  end

  resources :accounts, :only => [:new, :create] do
    get :confirm, :on => :member, :path => 'confirm(/:email_code)'
  end
  match "terms_of_service", :to => "accounts#terms_of_service", :as => "terms_of_service"

  # scope :via => :delete, :to => "participants#destroy" do
  #   match "/pictures/:picture_id/watch", :as => "watch_picture"
  #   match "/posts/:thought_id/watch", :as => "watch_thought"
  # end
end
