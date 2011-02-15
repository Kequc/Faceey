class Picture < ItemLinkable
  # include Mongoid::Document
  # include Mongoid::Timestamps

  mount_uploader :attach, (lambda { self.on_owners_profile? } ? ProfilePictureUploader : PictureUploader)

  field :content
  
  validates :content, :presence => true, :length => { :maximum => APP[:max_default_content_length] }
  # validates_attachment_presence :upload
  # validates_attachment_content_type :upload, :content_type => /image/
  
  after_create :update_profile_picture, :if => :on_owners_profile?
  after_create :increase_pictures_count
  after_destroy :decrease_pictures_count

  def remote_attach_url=(url)
    self.link_submitted = url
    super url
  end
  
  protected
  
  def update_profile_picture
    shared_by.cached_picture_id = self._id
    shared_by.cached_picture_filename = self.attach_filename
    shared_by.save
    shared_by.propagate_picture
  end
  
  def on_owners_profile?
    stream_id == shared_by_id
  end
  
  def increase_pictures_count
    shared_by.inc(:pictures_count, 1)
  end
  
  def decrease_pictures_count
    shared_by.inc(:pictures_count, -1)
  end
end
