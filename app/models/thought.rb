class Thought < ItemLinkable
  # include Mongoid::Document
  # include Mongoid::Timestamps

  field :content
  
  validates :content, :presence => true, :length => {:maximum => APP[:max_default_content_length]}
end
