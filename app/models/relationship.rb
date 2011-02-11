class Relationship
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :block, :type => Boolean, :default => false
  field :blocked, :type => Boolean, :default => false
  field :hidden, :type => Boolean, :default => false
  field :friend, :type => Boolean, :default => false
  field :friended, :type => Boolean, :default => false

  embedded_in :profile, :inverse_of => :relationships
end
