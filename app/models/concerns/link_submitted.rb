module LinkSubmitted
  def self.included(base)
    base.referenced_in :existing_link
    base.embeds_one :link
    
    base.after_create :process_link_url
  end

  def link_submitted=(url)
    url = URI.unescape(url.strip).sub(Regexp.new('(http|https):\/\/(www.)?'+APP[:site_domain], true), '')
    unless url.blank?
      self.build_link(:url => url)
    end
  end
  
  def link_url_is_local_path?
    link.url.match(/^\//) ? true : false
  end
  
  def has_link?
    link and !link.url.blank?
  end
  
  def attach_link
    l = ExistingLink.find_and_decorate_url(link.url)
    self.existing_link = l
    self.link.attributes = l.build_link_attributes
    self.save
    self.propagate_link_submitted if self.respond_to?('propagate_link_submitted')
  end
  handle_asynchronously :attach_link
  
  protected
  
  def process_link_url
    self.attach_link if self.has_link? and !self.link_url_is_local_path?
  end
end
