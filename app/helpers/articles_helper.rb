module ArticlesHelper
  PREVIEW_CONTENT_MAX_LENGTH = 144

  def article_published_pill(article)
    if article.published?
      '<span class="badge badge-pill badge-danger">Článok je zverejnený!</span>'.html_safe
    else
      '<span class="badge badge-pill badge-warning">Článok nie je zverejnený.</span>'.html_safe
    end
  end
end
