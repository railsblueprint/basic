class Setting < ApplicationRecord
  self.inheritance_column = nil

  enum type: { set: 0, string: 1, integer: 2, boolean: 3, json: 4 }

  default_scope -> { where(deleted_at: nil) } if Rails.env.development?

  scope :unsaved, -> { unscoped.where.not(deleted_at: nil).or(Setting.where(not_migrated: true)) }

  # returns array of possible types with translation for use in selects in forms
  def self.type_enum
    types.map { |t| [type_text(t[0]), t[0].to_sym] }
  end

  def self.type_text type
    I18n.t(type, scope: [:activemodel, :attributes, :setting, :types])
  end

  def type_text
    self.class.type_text type
  end

  def parsed_json_value
    parsed = begin
      JSON.parse(value)
    rescue StandardError
      nil
    end
    parsed.is_a?(Hash) ? parsed.with_indifferent_access : parsed
  end

  # rubocop:disable Style/MissingRespondToMissing
  def self.method_missing method, *_args
    self[method]
  end
  # rubocop:enable Style/MissingRespondToMissing

  def self.[] name
    s = find_by(alias: name)
    return nil unless s
    return s.value.to_i if s.integer?
    return s.value.to_b if s.boolean?
    return s.parsed_json_value if s.json?

    s.value
  end

  def self.get(name)
    self[name]
  end

  def self.to_liquid
    all.filter_map { |s|
      { s.alias => s.value } unless s.set?
    }.reduce(&:merge)
  end
end
