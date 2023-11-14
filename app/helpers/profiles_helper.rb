module ProfilesHelper
  def render_safe(content)
    do_safe(do_sanitize(content))
  end

  def do_safe(content)
    content.html_safe
  end

  def do_sanitize(content)
    Sanitize.clean(content, Sanitize::Config::RELAXED)
  end
end
