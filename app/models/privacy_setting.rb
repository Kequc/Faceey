class PrivacySetting
  include Mongoid::Document
  
  field :title
  field :value, :type => Integer

  # TODO: These were the default settings
  # field :perm_email, :type => Integer, :default => 0
  # field :perm_birthday, :type => Integer, :default => 1
  # field :perm_messages, :type => Integer, :default => 1

  embedded_in :profile, :inverse_of => :privacy_settings

  # Cast      Value
  #
  # NO ONE    0
  # ALLOW     1
  # FRIENDS   2
  #
  validates :value, :inclusion => {:in => [0,1,2]}
end
