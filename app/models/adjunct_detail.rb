class AdjunctDetail
  include Mongoid::Document
  include SharedBy
  
  field :content
  field :created_at, :type => DateTime
  
  embedded_in :adjunct, :inverse_of => :adjunct_details

  class << self
    def not_blocked
      not_in(:shared_by_id => Profile.current.blocked_relationship_ids)
    end
  end
  
  def comment=(comment)
    # Primary functionality is to reference comments
    self.attributes = {
      :_id => comment._id,
      :shared_by_id => comment.shared_by_id,
      :cached_full_name => comment.cached_full_name,
      :content => comment.content,
      :created_at => comment.created_at }
  end
end
