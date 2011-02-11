class Stream
  include Mongoid::Document
  
  references_many :splashes, :default_order => :created_at.desc, :dependent => :destroy
end
