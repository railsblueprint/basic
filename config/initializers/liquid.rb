require_relative "../../app/liquid/i18n_tag"

Liquid::Template.register_tag("t", I18nTag)
Liquid::Template.register_tag("translate", I18nTag)
