class Splash
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :stream
  
  def self.from_stream(s)
    where(:stream_id => s._id)
  end
  
  def self.exclude_blocked
    return criteria unless Profile.current
    not_in(:shared_by_id => Profile.current.blocked_relationship_ids)
  end
end
