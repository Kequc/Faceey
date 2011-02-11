class Adjunct
  include Mongoid::Document
  
  field :cached_type
  field :shared_by_id
  
  embedded_in :profile, :inverse_of => :adjuncts
  embeds_many :adjunct_details
  
  class << self
    def not_blocked
      not_in(:shared_by_id => Profile.current.blocked_relationship_ids)
    end
  end
  
  def unread_count
    adjunct_details.not_blocked.length
  end
  
  def first_unread
    adjunct_details.not_blocked.asc(:created_at).first
  end
end
