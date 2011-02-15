module ProfileHelper
  def image_stream_link(object, type=:thumb, concealable=false)
    if signed_in?
      return (admin_link_toggle(object, concealable).to_s + stream_picture(object, type)).html_safe
    else
      return stream_picture(object, type)
    end
  end

  def admin_link_toggle(object, concealable=false)
    return nil if current_profile_id?(object.shared_by_id)
    dropdown = []
    dropdown << content_tag(:li, link_to("View profile", profile_path(object.shared_by_id)))
    # dropdown << content_tag(:li, link_to("Picture", stream_picture_url(object), :class => "gb"))
    if signed_in?
      unless friended_id?(object.shared_by_id) or blocked_id?(object.shared_by_id)
        dropdown << content_tag(:li, link_to("Start sharing", toggle_friend_relationship_path(object.shared_by_id)))
      end
      if concealable and friend_id?(object.shared_by_id)
        dropdown << content_tag(:li, link_to((hidden_id?(object.shared_by_id) ? "Un-hide" : "Hide"), toggle_hide_relationship_path(object.shared_by_id)))
      end
      if friended_id?(object.shared_by_id)
        dropdown << content_tag(:li, link_to("Sharing", relationship_path(object.shared_by_id)))
      else
        dropdown << content_tag(:li, link_to("Block", toggle_block_relationship_path(object.shared_by_id)))
      end
    end
    content_tag(:div, content_tag(:ul, dropdown.join.html_safe, :class => "controls"), :class => "admin_toggle")
  end

  def stream_picture(object, type=:big, link=nil)
    class_name = type.to_s
    link = !blocked_id?(object._id) if link.nil?
    image = image_tag(stream_picture_url(object, type), :alt => "")
    if link
      return link_to(image, profile_path(object.shared_by_id), :class => class_name)
    else
      return content_tag(:div, image, :class => class_name)
    end
  end

  def stream_picture_url(object, type=nil)
    object.cached_picture_url(type)
  end

  def describe_relationship(relationship, profile)
    link = (blocked_id?(profile._id) ? profile.full_name : link_to(profile.full_name, profile_path(profile)))
    if relationship.blocked
      output = "You have <strong>BLOCKED</strong> #{link}"
    elsif relationship.friended
      output = "You are sharing with #{link}"
    else
      output = "You are <em><u>not</u></em> sharing with #{link}"
    end
    raw output
  end
  
  def describe_colleague_relationship(relationship)
    if relationship.block
      output = "They have blocked you"
    elsif relationship.friend
      output = "They are sharing with you"
    else
      output = "They are <u>not</u> sharing with you"
    end
    raw output
  end
end
