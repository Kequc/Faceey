module SharedBy
  def self.included(base)
    base.field :cached_full_name
    
    base.referenced_in :shared_by, :class_name => 'Profile'
    
    base.before_create :assign_ownership
  end

  protected
  
  def assign_ownership
    self.shared_by = Profile.current if self.shared_by_id.blank?
    self.cached_full_name = self.shared_by.to_s if self.cached_full_name.blank?
  end
end
