module FormHelper
  def render_check_box(form, field, text, checked=nil)
    cb = checked.nil? ? form.check_box(field) : form.check_box(field, :checked => checked)
    content_tag(:p, form.label(field, cb + "<span>#{text}</span>".html_safe), :class => "check_box")
  end

  def errors_for(object, message=nil)
    return nil unless object.errors.any?
    if message.blank?
      message = pluralize(object.errors.size, 'problem')
    end  
    errors = []
    object.errors.full_messages.each do |msg|
      errors << content_tag(:li, msg)
    end
    return content_tag(:div, content_tag(:div, message, :class => "header primary_bg") + content_tag(:ul, errors.join("\n").html_safe), :class => "form_errors").html_safe
  end
end
