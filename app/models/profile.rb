class Profile < Stream
  # include Mongoid::Document
  include Mongoid::Timestamps
  include CachedPicture

  field :first_name
  field :last_name
  index [:first_name, :last_name]
  field :gender
  field :birthday, :type => Date
  field :description
  field :blurb
  field :blog_title
  field :pictures_count, :type => Integer, :default => 0
  field :last_item_at, :type => DateTime
  index :last_item_at

  references_many :items, :inverse_of => :shared_by
  references_many :pebbles, :inverse_of => :shared_by
  referenced_in :account
  embeds_many :privacy_settings
  embeds_many :relationships
  embeds_many :adjuncts

  cattr_accessor :current
  validates :first_name, :length => { :minimum => 3, :maximum => 50 }
  validates :last_name, :length => { :maximum => 50 }
  validates :gender, :inclusion => { :in => [nil, "", "Male", "Female"] }
  # validates :birthday, :date => { :before => Time.now, :after => Time.now-106.years, :message => "invalid" }, :allow_nil => true
  validates :description, :length => { :maximum => APP[:max_default_content_length] }
  validates :blurb, :length => { :maximum => APP[:max_default_blurb_length] }
  validates :terms_of_service, :acceptance => true
  
  scope :order_by_name, desc(:first_name).desc(:last_name)
  
  before_save :check_name_changed
  
  def propagate_picture
    attributes = { "cached_picture_id" => self.picture._id, "cached_picture_filename" => self.picture.attach_filename }
    Item.collection.update({ "shared_by_id" => self._id }, { "$set" => attributes }, :multi => true)
    Comment.collection.update({ "shared_by_id" => self._id }, { "$set" => attributes }, :multi => true)
  end
  handle_asynchronously :propagate_picture
  
  def propagate_name
    attributes = { "cached_full_name" => self.full_name }
    Item.collection.update({ "shared_by_id" => self._id }, { "$set" => attributes }, :multi => true)
    Item.collection.update({ "shared_by_id" => { "$ne" => self._id}, "stream_id" => self._id }, { "$set" => { "cached_shared_to" => self.full_name } }, :multi => true)
    Comment.collection.update({ "shared_by_id" => self._id }, { "$set" => attributes }, :multi => true)
  end
  handle_asynchronously :propagate_name
  
  def full_name
    "#{first_name} #{last_name}".strip
  end
  alias_method :to_s, :full_name
  alias_method :cached_full_name, :full_name
  
  def shared_by
    self
  end

  def shared_by_id
    self._id
  end
  
  def can_modify?(object)
    # Object was created by signed in user
    Profile.current and object.shared_by_id == Profile.current._id
  end
  
  def blocked_relationship_ids
    relationships.any_of({ :blocked => true }, { :block => true }).collect(&:_id)
  end
  
  def friend_relationship_ids
    relationships.where(:friend => true).collect(&:_id)
  end
  
  def friended_relationship_ids
    relationships.where(:friended => true).collect(&:_id)
  end
  
  def hidden_relationship_ids
    relationships.where(:hidden => true).collect(&:_id)
  end
  
  def permission?(perm)
    p = self.privacy_settings.find_by_short_name(perm)
    return false unless p
    [false, true, is_friend?][p.value]
  end
  
  def adjuncts_count
    len = 0
    adjuncts.not_blocked.each do |adjunct|
      len += 1 if adjunct.unread_count > 0
    end
    len
  end
  
  def has_adjuncts?
    adjuncts_count > 0
  end
  
  def is_current_profile?
    if u = Profile.current and self.is_a?(Profile)
      return u.id == id
    end
    false
  end
  
  protected
  
  def check_name_changed
    if persisted? and (first_name_changed? or last_name_changed?)
      propagate_name
    end
  end
end
