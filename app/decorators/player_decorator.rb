class PlayerDecorator < SimpleDelegator
  def name
    [first_name, last_name].compact.join(' ')
  end
end
