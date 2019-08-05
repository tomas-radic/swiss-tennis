module ArticlesHelper
  PREVIEW_CONTENT_MAX_LENGTH = 144

  def preview_content(article)
    result = article.content[0...PREVIEW_CONTENT_MAX_LENGTH]

    if article.content.length > PREVIEW_CONTENT_MAX_LENGTH
      result += '... '
      result += link_to('(dočítať celé)', article_path(article))
    end

    result.html_safe
  end
end
