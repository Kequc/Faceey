module CachedPicture
  def self.included(base)
    base.field :cached_picture_id
    base.field :cached_picture_filename
    
    base.before_create :cache_picture
  end
  
  def has_picture?
    !self.cached_picture_id.blank?
  end
  
  def picture
    Picture.find(cached_picture_id) rescue nil
  end
  
  def cached_picture_url(type=nil)
    dir = "profile"
    dir = "blocked" if Profile.current and Profile.current.blocked_relationship_ids.include?(self._id)
    return "placeholders/#{dir}/#{(type ? type.to_s+"_" : "")}photo.png" if dir == "blocked" or !self.has_picture?
    filename = self.cached_picture_filename
    filename = "#{type}_#{filename}" if type
    "/resource/pictures/#{self.cached_picture_id}/#{filename}"
  end
  
  protected
  
  def cache_picture
    stream = Profile.current
    if stream and stream.has_picture?
      self.cached_picture_id = stream.picture._id
      self.cached_picture_filename = stream.picture.attach_filename
    end
  end
end
