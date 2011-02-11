module TextHelper
  def text_with_count(text, num)
    text += " <span class=\"count\">#{num}</span>".html_safe if num > 0
    text
  end

  def stub(time, arr=nil)
    output = content_tag(:span, (time.is_a?(Time) ? display_time_ago(time) : time), :class => "time")
    output += arr.unshift("").join(" &middot; ").html_safe if arr and !arr.empty?
    content_tag(:div, output, :class => "stub")
  end
  
  def faceey_text_format(content, links=false, sanitized=false)
    return nil if content.blank?
    content = h(content) unless sanitized
    if links
      content = auto_link(content, :all, :target => "_blank") do |text|
        shorten_link(text)
      end
    end
    simple_format(content)
  end

  def strong_text_with_count(text, num, class_name="link")
    text = content_tag(:strong, text)
    content_tag(:span, text_with_count(text, num), :class => class_name)
  end

  def faceey_name_title_and_content(object, links=true, content=:content)
    faceey_text_format(name_title_and_content(object, content), links).html_safe
  end

  def name_title_and_content(object, content=:content)
    content = object.read_attribute(content)
    (name_title(object) + " " + h(content)).html_safe
  end
  
  def remove_newlines(text)
    text.gsub(/(\r)?\n/, " ")
  end
  
  def ellipsis(text, length)
    truncate(text.strip, :length => length, :omission => "...")
  end

  def name_title(object, ignore_secondary=false)
    text = content_tag(:span, h(object.cached_full_name), :class => "shared_by")
    if object.respond_to?('cached_shared_to') and object.show_shared_to?
      text += content_tag(:span, " &rarr; #{h(object.cached_shared_to)}".html_safe, :class => "shared_to")
    end
    content_tag(:span, text, :class => "info").html_safe
  end

  def truncate_text(text, sanitized=true, max=1400, lines=5)
    long = (text.strip.length > max or text.split(/\r?\n/)[lines])
    # long = (text.length > max)
    text = text.split(/\r?\n/)[0..lines-1].join("\n").strip
    # text = truncate(text, max, "")
    if long
      return faceey_text_format(ellipsis(text, max-500), false, sanitized)
    end
    faceey_text_format(text, false, sanitized)
  end
end
