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

  def maybe_missing(value)
    return value unless value.blank?

    '(chýba)'
  end

  def formatted_phone(phone)
    return phone if phone.blank?

    phone.reverse.insert(3, ' ').insert(7, ' ').reverse
  end

  def link_to_manager_phone(link_text = nil)
    link_text ||= '0908 304 473'
    link_to link_text, 'tel:0908304473'
  end

  def flash_values(type)
    return [nil, nil] unless ['notice', 'alert'].include? type

    flash_class = 'alert alert-dismissible fade show'
    flash_message = 'Ok, vybavené.'

    case type
    when 'notice'
      flash_class += ' alert-success alert-auto-dismiss'
    when 'alert'
      flash_class += ' alert-danger'
      flash_message = 'Upss, stala sa chyba. Ak je to potrebné, volaj, alebo píš.'
    end

    [flash_class, flash_message]
  end

  def currency_string(amount)
    "#{sprintf('%0.2f', amount / 100.0)} €"
  end
end
