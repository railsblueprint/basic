class DelayedCommandJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/MethodLength, Metrics/BlockLength
  def perform(klass, attributes={})
    unless klass.is_a?(Class) && klass < BaseCommand
      log_error("DelayedCommandJob must be used with BaseCommand descendants. called for #{klass.inspect} with " \
                "#{attributes.inspect}")
      return
    end
    klass.call(attributes) do |command|
      command.on(:abort) do
        log_error(
          "Background execution of command aborted",
          class:      klass,
          attributes:
        )
      end
      command.on(:invalid) do |errors|
        log_error(
          "Background execution of command blocked by invalid arguments",
          class:      klass,
          attributes:,
          errors:
        )
      end
      command.on(:stale) do
        log_error(
          "Background execution of command skipped because of stale data",
          class:      klass,
          attributes:
        )
      end
      command.on(:unauthorized) do
        log_error(
          "Background execution of command is not authorized",
          class:      klass,
          attributes:
        )
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/BlockLength

  def log_error(message, context={})
    Rails.logger.error(message)
    Rails.logger.error("context: #{context.inspect}") if context.present?
  end
end
