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
    existing_link = ExistingLink.find_or_initialize_by(:url => (attrs["url"].blank? ? url : attrs["url"]))
    if ["picture", "video", "rich", "link"].include?(attrs["type"].to_s.strip)
      existing_link.build_link(
        :variety => attrs["type"],
        :provider_name => attrs["provider_name"],
        :title => attrs["title"],
        :description => attrs["description"])
      existing_link.remote_attach_url = attrs["thumbnail_url"] unless existing_link.persisted?
    elsif url =~ Regexp.new(APP[:image_regex], true)
      existing_link.build_link(:variety => "picture")
      existing_link.remote_attach_url = url unless existing_link.persisted?
    end
    existing_link.save
    return existing_link
  end

  def build_link_attributes
    attrs = {}
    if link
      attrs = link.attributes.reject{ |k| [:variety, :provider_name, :title, :description].include?(k) }
    end
    attrs[:attach_url] = attach_url
    return attrs
  end
end
