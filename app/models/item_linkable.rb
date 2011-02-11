class ItemLinkable < Item
  # include Mongoid::Document
  # include Mongoid::Timestamps
  include LinkSubmitted

  before_destroy :depropagate_link_submitted
  
  def propagate_link_submitted
    linkables = ItemLinkable.where(:existing_link_id => self.existing_link_id).excludes(:_id => self._id).all
    if linkables.length > 0 and SharedLink.where(:existing_link_id => self.existing_link_id, :shared_by_id => self.shared_by_id).count < 1
      SharedLink.create(
        :existing_link_id => self.existing_link_id,
        :items => linkables,
        :shared_from => self )
    end
  end

  protected
  
  def depropagate_link_submitted
    if self.link
      SharedLink.destroy_all(:conditions => { :shared_from_id => self._id })
    end
  end
end
