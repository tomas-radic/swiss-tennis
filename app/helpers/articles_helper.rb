module ArticlesHelper

  PREVIEW_CONTENT_MAX_LENGTH = 250
  TILE_CONTENT_MAX_LENGTH = 1000


  def article_published_pill(article)
    if article.published?
      '<span class="badge badge-pill badge-danger">Článok je zverejnený!</span>'.html_safe
    else
      '<span class="badge badge-pill badge-warning">Článok nie je zverejnený.</span>'.html_safe
    end
  end


  def article_preview_content(article)
    article.content[0...PREVIEW_CONTENT_MAX_LENGTH]
  end


  def article_exceeding_preview?(article)
    article.content.length > PREVIEW_CONTENT_MAX_LENGTH
  end


  def link_to_article(article, expand_content = false)
    if expand_content
      if article.content.length <= TILE_CONTENT_MAX_LENGTH
        link_to("(dočítať celé)", load_content_article_path(article), remote: true)
      else
        link_to("(dočítať celé)", article_path(article))
      end
    else
      link_to("(dočítať celé)", article_path(article))
    end
  end
end
