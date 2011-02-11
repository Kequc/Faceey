class Pebble
  include Mongoid::Document
  include Mongoid::Timestamps
  
  references_and_referenced_in_many :items
end
