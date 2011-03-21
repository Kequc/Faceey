class Account
  include Mongoid::Document
  include BCrypt

  field :email
  index :email
  field :password_hash
  field :confirmed, :type => Boolean, :default => false
  field :new_email
  field :email_code
  field :password_code
  field :password_code_sent_at, :type => DateTime

  references_one :profile, :autosave => true
  accepts_nested_attributes_for :profile
  validates_associated_attributes :profile

  attr_accessor :password
  validates :profile, :presence => true
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :password, :length        => { :minimum => 4, :maximum => 40 },
                       :confirmation  => true,
                       :if            => :should_validate_password?

  before_save :hash_password, :if => :should_validate_password?
  before_save :restore_changed_email
  
  def self.authenticate(email, password)
    account = where(:email => email).first
    if account and account.has_password?
      return account if Password.new(account.password_hash) == password
    end
    return nil
  end
  
  def full_name
    has_profile? ? profile.full_name : email
  end
  alias_method :to_s, :full_name

  def self.generate_code
    ActiveSupport::SecureRandom.hex(4)
  end
  
  def password_code_verifies?(code)
    if !has_password? and !new_email
      # Account is new
      return true
    end
    password_code and password_code == code and password_code_sent_at and password_code_sent_at > 5.days.ago
  end
  
  def can_login?
    profile and password and !password.blank?
  end
  
  def has_profile?
    profile
  end
  
  def has_password?
    !password_hash.blank?
  end
  
  def email_to_string(address=nil)
    address ||= email
    address = "#{profile.full_name} <#{address}>" if profile
    return address
  end
  
  protected

  def hash_password
    self.password_hash = Password.create(password)
  end

  def should_validate_password?
    !self.persisted? or password.present?
  end
  
  def restore_changed_email
    if !self.persisted? or self.email_changed?
      self.new_email = self.email
      self.email = self.email_was
      self.email_code = Account.generate_code
      AccountMailer.email(self).deliver
    end
  end
end
