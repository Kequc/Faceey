module LinkHelper
  def attached_link(object)
    if object.has_link?
      content = []
      class_name = "attached_link"
      unless object.link.attach_url.blank?
        content << image_tag(object.link.attach_url, :class => "thumbnail")
      end
      content << content_tag(:div, ellipsis(object.link.title, 150), :class => "title") unless object.link.title.blank?
      content << content_tag(:div, ellipsis(remove_newlines(object.link.description), 225), :class => "description") unless object.link.description.blank?
      class_name += " #{object.link.variety}_link" if object.link.variety
      unless object.link_url_is_local_path?
        class_name += " gb"
        target = "_blank"
      end
      content << content_tag(:div, shorten_link(object.link.url), :class => "url")
      return link_to(content.join("\n").html_safe, object.link.url, :target => target, :class => class_name)
    end
  end
  
  def uploaded_picture(object)
    if object.respond_to?('attach')
      class_name = "uploaded_picture gb"
      image = image_tag(object.attach.url(:tiny), :alt => "", :class => "thumbnail")
      image += content_tag(:div, object.link.url, :class => "original") if object.has_link?
      return link_to(image, object.attach.url, :target => "_blank", :class => class_name)
    end
  end

  def shorten_link(text)
    max = 55
    return text if text.strip.length < max
    ellipsis(text, max-18) + text.match(/.{15}$/).to_s
  end
  
  # def parse_url(url)
  #   uri = Addressable::URI.parse(url)
  #   case uri.host
  #   when /^(www.)?youtube\.com/
  #     {:website => "youtube", :id => uri.query_values[:v]}
  #   when /^(www.)?vimeo\.com/
  #     {:website => "vimeo", :id => uri.path.split('/')[0]}
  #   end
  # end
end
