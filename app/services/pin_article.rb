class PinArticle < Patterns::Service
  pattr_initialize :article

  def call
    pin_article!
  end

  private

  def pin_article!
    article.touch
    article.update!(new_attribute_values)
  end

  def new_attribute_values
    result = { published: true }

    if article.last_date_interesting && article.last_date_interesting < Date.today
      result[:last_date_interesting] = Date.today + 5.days
    end

    result
  end
end
