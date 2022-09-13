class I18nTag < Liquid::Tag
  def render(_context)
    key = @markup.split(/\s+/).first

    I18n.t(key)
  end
end
