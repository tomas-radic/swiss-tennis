module ApplicationHelper
  def add_error_class_to(classes, obj, attribute_to_check)
    classes += ' field-error' if obj.errors[attribute_to_check].present?
    classes
  end
end
