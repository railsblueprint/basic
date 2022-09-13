module Settings
  class MassUpdateCommand < BaseCommand
    attribute :settings, Types::Hash
    attribute :current_user, Types::Nominal(User)

    validate :ids_are_present

    def process
      update_settings
    end

    def update_settings
      records.each do |setting|
        setting.update!(value: settings[setting.id][:value])
      end
    end

    def settings_ids
      settings.keys
    end

    def ids_are_present
      return if records.size == settings_ids.count

      errors.add(:base, :invalid_id,
                 message: "Invalid settings ids: #{(settings_ids - records.map(&:id)).join(', ')}")
    end

    memoize def records
      Setting.where(id: settings_ids).to_a
    end

    def authorized?
      Pundit.policy!(current_user, Setting).mass_update?
    end
  end
end
