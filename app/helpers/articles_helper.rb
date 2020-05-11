module ArticlesHelper
  PREVIEW_CONTENT_MAX_LENGTH = 244

  def article_published_pill(article)
    if article.published?
      '<span class="badge badge-pill badge-danger">Článok je zverejnený!</span>'.html_safe
    else
      '<span class="badge badge-pill badge-warning">Článok nie je zverejnený.</span>'.html_safe
    end
  end

  def tile_content_for(article)
    result = article.content[0...PREVIEW_CONTENT_MAX_LENGTH]
    if article.content.length > PREVIEW_CONTENT_MAX_LENGTH
      result += " ... #{link_to('(dočítať celé)', article_path(article))}"
    end

    result.html_safe
  end
end
