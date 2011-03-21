module LayoutHelper
  def title(content)
    @page_title = content
  end

  def render_item(item, concealable=false)
    shared_by = image_stream_link(item, :thumb, concealable)
    type = item._type.underscore
    rendered_item = render("#{type.tableize}/#{type}", :object => item)
    content_tag(:div, shared_by + rendered_item , :id => "splash_#{item._id}", :class => "shared profile_#{item.shared_by_id}")
  end
  
  def render_comment(comment, op=true)
    shared_by = image_stream_link(comment, :tiny)
    type = "comment"
    rendered_comment = render("comments/#{type}", :object => comment)
    class_name = "comment shared profile_#{comment.shared_by_id} " + (op ? "op" : "non_op")
    content_tag(:div, shared_by + rendered_comment , :id => "comment_#{comment._id}", :class => class_name)
  end
  
  def paginate(query, options={}, &block)
    options = { :text => "content", :desc => false, :field => :created_at, :per_page => APP[:per_page] }.merge(options)
    rev, vis = options[:desc], options[:per_page]
    if params[:starting]
      time = Time.at(params[:starting].to_i)
      params.delete(:ending)
    elsif params[:ending]
      time = Time.at(params[:ending].to_i)
      rev = !rev
    end
    objects = query.fuse(:limit => options[:per_page]+1, :order_by => options[:field].send(rev ? :desc : :asc))
    if params[:comment_id] and comment = Comment.where(:_id => params[:comment_id]).first
      num = query.where(:created_at.lte => comment.created_at).count
      objects = objects.fuse(:offset => ((num-1)/options[:per_page])*options[:per_page]).cache
      prev_count = num-objects.length
    else
      if time
        objects = objects.fuse(:where => { options[:field].send(rev ? :lte : :gte) => time })
        prev_count = query.where(options[:field].send(options[:desc] ? :gt : :lt) => time).count
      end
      objects = objects.cache
      if params[:ending]
        objects = objects.reverse
        prev_count -= objects.length-1
        if objects.length <= options[:per_page]
          vis = objects.length-1
        end
      end
    end
    return options[:empty] unless objects.length > 0
    output = []
    if prev_count.to_i > 0
      output << display_pagination("Previous #{options[:text]} #{prev_count}", :ending => objects[0].created_at.to_i)
    end
    objects.slice(0, vis).each do |object|
      output << capture(object, &block)
    end
    if next_object = objects.slice(vis)
      output << display_pagination("More #{options[:text]}", :starting => next_object.created_at.to_i)
    end
    output.join("\n").html_safe
  end
  
  def display_empty
    content_tag(:div, content_tag(:p, "Empty"), :class => "block")
  end

  def display_pagination(text, link=nil)
    content_tag(:div, link_to(text, link), :class => "pagination")
  end

  def display_time_ago(created_at)
    if 1.year.ago > created_at
      return created_at.strftime('%A, %B %d %Y')
    elsif 1.day.ago > created_at
      return created_at.strftime('%A, %B %d')
    else
      return time_ago_in_words(created_at) + ' ago'
    end
  end
  
  def legend(text)
    content_tag(:div, content_tag(:span, text), :class => "legend primary_bg")
  end
  
  def stop_following_conversation_link(watchable, path)
    if watchable.is_watched?(current_profile)
      return panel_special("You are currently following this conversation. If you would like you may "+link_to("stop", path, :confirm => "Are you sure?", :method => :delete)+" following.")
    end
  end
  
  def panel_special(text)
    content_tag(:div, image_tag("arrow_left.png", :alt => "") + text.html_safe, :class => "arrow_left")
  end
  
  def panel(object, control=nil, dir_name=nil)
    return nil if !dir_name and !object
    dir_name ||= object.class.to_s.tableize
    @current_page = control
    @right_panel = dir_name
    content_for :right_panel do
      render :partial => "#{dir_name}/panel", :object => object
    end
  end
  
  def named_panel(name, control=nil)
    panel(nil, control, name)
  end
  
  def controls_link(text, link, this_page=nil)
    content_tag(:li, link_to(text, link.to_s, :class => matches_current_page?(this_page) ? "current" : nil))
  end
  
  def matches_current_page?(value)
    !value.blank? and @current_page.to_s == value.to_s
  end

  def stream_blurb(stream)
    return nil if stream.blurb.blank?
    content_tag(:div, faceey_text_format(stream.blurb, true), :class => "blurb")
  end

  def add_item(stream)
    render :partial => "items/add_item", :object => stream
  end
  
  def add_comment(item)
    render :partial => "comments/add_comment", :object => item
  end
end
