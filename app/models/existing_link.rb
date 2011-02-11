class ExistingLink
  include Mongoid::Document
  
  mount_uploader :attach, LinkThumbnailer

  field :url
  
  references_many :shared_links
  references_many :comments
  references_many :thoughts
  embeds_one :link
  
  def self.find_and_decorate_url(url)
    attrs = Embedly.get_attrs(url)
    link = ExistingLink.find_or_initialize_by(:url => (attrs["url"].blank? ? url : attrs["url"]))
    if ["picture", "video", "rich", "link"].include? attrs["type"]
      link.build_link(
        :variety => attrs["type"],
        :provider_name => attrs["provider_name"],
        :title => attrs["title"],
        :description => attrs["description"] )
      link.remote_attach_url = attrs["thumbnail_url"] unless link.persisted?
    elsif url =~ Regexp.new(APP[:image_regex], true)
      link.build_link(:variety => "picture")
      link.remote_attach_url = url unless link.persisted?
    end
    link.save
    return link
  end
end
