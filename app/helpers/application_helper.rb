module ApplicationHelper
  def add_error_class_to(classes, obj, attribute_to_check)
    classes += ' field-error' if obj.errors[attribute_to_check].present?
    classes
  end

  def double_confirm_button(title, target_path, btn_class = 'btn btn-sm btn-success')
    result_html = "<button class=\"#{btn_class} btn-dbl-confirm\">#{title}</button>"
    result_html += "<span class=\"span-dbl-confirm\">"
    result_html += "<button class=\"btn btn-sm btn-success btn-cancel-confirmation\">X</button>"
    result_html += link_to('Potvrdiť!', target_path, class: 'btn btn-sm btn-outline-danger mx-1')
    result_html += "</span>"
    result_html.html_safe
  end
end
