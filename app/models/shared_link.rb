class SharedLink < Pebble
  # include Mongoid::Document
  # include Mongoid::Timestamps
  include SharedBy

  referenced_in :existing_link, :inverse_of => :shared_links
  referenced_in :shared_from, :class_name => 'Item', :inverse_of => :shared_link
end
