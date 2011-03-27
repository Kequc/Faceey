module FormHelper
  def render_check_box(form, field, text, checked=nil)
    cb = checked.nil? ? form.check_box(field) : form.check_box(field, :checked => checked)
    content_tag(:p, form.label(field, cb + "<span>#{text}</span>".html_safe), :class => "check_box")
  end

  def errors_for(object, message=nil)
    return nil unless object.errors.any?
    list_errors = []
    object.errors.full_messages.each do |msg|
      list_errors << content_tag(:li, msg)
    end
    return content_tag(:div, content_tag(:ul, list_errors.join("\n").html_safe), :class => "form_errors").html_safe
  end
end
