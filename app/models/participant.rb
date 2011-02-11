class Participant
  include Mongoid::Document
  
  field :comment_count, :type => Integer, :default => 0
  field :watching, :type => Boolean, :default => true
  
  embedded_in :item, :inverse_of => :participants
end
