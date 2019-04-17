class RoundDecorator < SimpleDelegator
  def full_label
    ["Kolo #{position}", label].reject(&:blank?).join(', ')
  end
end
