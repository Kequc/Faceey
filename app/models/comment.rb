class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include LinkSubmitted
  include SharedBy
  include CachedPicture
  include Rails.application.routes.url_helpers

  field :content

  referenced_in :item, :inverse_of => :comments
  
  validates :content, :presence => true, :length => { :maximum => APP[:max_default_content_length] }
  
  after_create :increase_comments_count
  after_destroy :decrease_comments_count
  after_create :update_participants
  
  attr_accessor :link_submitted
  
  protected

  def increase_comments_count
    participant = item.participants.find_or_create_by(:_id => self.shared_by_id)
    participant.update_attributes(:watching => true, :comment_count => participant.comment_count+1)
  end

  def decrease_comments_count
    participant = item.participants.find(self.shared_by_id)
    if participant.comment_count == 1
      participant.delete
    else
      participant.update_attribute(:comment_count, participant.comment_count-1)
    end
  end
  
  def update_participants
    item.update_participants(self)
  end
end
