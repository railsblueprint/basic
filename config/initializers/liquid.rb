require_relative "../../app/liquid/i18n_tag"

Liquid::Environment.default.register_tag("t", I18nTag)
Liquid::Environment.default.register_tag("translate", I18nTag)
