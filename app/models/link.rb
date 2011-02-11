class Link
  include Mongoid::Document

  field :url
  field :variety
  field :provider_name
  field :title
  field :description
  field :attach_url
  
  embedded_in :existing_link, :inverse_of => :link
  embedded_in :comment, :inverse_of => :link
  embedded_in :picture, :inverse_of => :link
  embedded_in :thought, :inverse_of => :link
end
