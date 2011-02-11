class Item < Splash
  # include Mongoid::Document
  # include Mongoid::Timestamps
  include SharedBy
  include CachedPicture
  
  field :cached_shared_to
  
  references_many :comments, :inverse_of => :item
  references_and_referenced_in_many :pebbles
  references_one :shared_link, :inverse_of => :shared_from
  embeds_many :participants

  before_create :cache_shared_to
  before_create :include_shared_by_in_participant_ids

  attr_accessor :link_submitted, :remote_attach_url
  
  def show_shared_to?
    self.stream_id != self.shared_by_id
  end
  
  def comments_count
    return participants.collect(&:comment_count).sum unless Profile.current
    participants.not_in(:_id => Profile.current.blocked_relationship_ids).collect(&:comment_count).sum
  end
  
  def participant_ids
    participants.where(:watching => true).collect(&:_id)
  end
  
  def clear_adjuncts
    if Profile.current and adjunct = Profile.current.adjuncts.where(:_id => self._id).first
      adjunct.delete
    end
  end
  
  def update_participants(comment)
    Profile.any_in(:_id => self.participant_ids-[comment.shared_by_id]).all.each do |participant|
      # Each participant gets notice
      adjunct = participant.adjuncts.find_or_initialize_by(:_id => self._id)
      unless adjunct.persisted?
        adjunct.shared_by_id = self.shared_by_id
        adjunct.cached_type = self._type
      end
      adjunct.adjunct_details.new(:comment => comment)
      adjunct.save
    end
  end
  handle_asynchronously :update_participants
  
  protected
  
  def cache_shared_to
    if self.show_shared_to?
      self.cached_shared_to = self.stream.to_s
    end
  end
  
  def include_shared_by_in_participant_ids
    self.participants = [Participant.new(:_id => Profile.current._id)]
  end
end
