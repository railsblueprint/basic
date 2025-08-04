#####################################################
# BaseCommand holds logic common to Command classes
#
# Command class is meant to be a class doing a single specific action,
# most suitable example - CRUD-like operations on models.
#
# Command class must be named by actions it performs (CreateSubscription, DeleteOrder, SendNotification)
# Command can have arguments, can do validations on arguments, can perform actions in background.
#
# Suggestion: if command will run in background, never pass objects as attributes,
# only object ids and then load needed object.
#
# Simple example:
#
# class DeleteOrder < BaseCommand
#   attribute :order_id, Types::Integer
#
#   def process
#     Order.find(order_id).destroy
#   end
# end
#
# Usage:
# Simple immediate call:
# DeleteOrder.call(order_id: 123)
#
# Run in background:
# DeleteOrder.call_later(order: 123)
#
# Run in background at specific time:
# DeleteOrder.call_at({wait: 5.minutes}, {order_id: 123})
#
# Sample with validations:
# class CreateOrder < BaseCommand
#   attribute :user_id, Types::Integer
#   attribute :name, Types::String
#
#   validates :name, :user, presence: true
#   validate :name_format
#
#   def process
#     Order.create(name: name, owner: user)
#   end
#
#   memoize def user
#     User.find_by(id: user_id)
#   end
#
#   def authorized?
#     user&.can?(:create_orders)
#   end
#
#   def name_format
#     return if name.blank?
#     return if name =~ /^PREFIX.*/
#
#     errors.add(:name, :invalid_format)
#   end
# end
#
# Setting default values for attributes:
# BaseCommand uses Dry::Initializer which requires default values to be wrapped in procs/lambdas:
#
# class NotificationCommand < BaseCommand
#   attribute :priority, Types::String, default: -> { "normal" }
#   attribute :retry_count, Types::Integer, default: -> { 3 }
#   attribute :send_at, Types::Time, default: -> { Time.current }
#   attribute :metadata, Types::Hash, default: -> { {} }
#   attribute :recipients, Types::Array, default: -> { [] }
#
#   def process
#     # When called without arguments, attributes have default values:
#     # priority => "normal"
#     # retry_count => 3
#     # send_at => <current time when instance is created>
#     # metadata => {} (new hash for each instance)
#     # recipients => [] (new array for each instance)
#   end
# end
#
# IMPORTANT: Default values MUST be procs/lambdas. Simple values will raise TypeError:
# attribute :name, Types::String, default: "John"  # WRONG! Raises TypeError
# attribute :name, Types::String, default: -> { "John" }  # Correct
#
# This ensures each instance gets its own copy of mutable objects (arrays, hashes)
#
# By default BaseCommand permits to omit all attributes. Any mandatory attribute must be checked with validations
#
# Use in controller:
# def create
#   CreateOrder.call(user_id: current.user_id, name: params[:name]) do |command|
#     command.on(:ok) do
#       render :success
#     end
#     command.on(:unauthorized) do
#       redirect_to :index, flash: {error: "You are not authorized"}
#     end
#     command.on(:invalid) do |errors|
#       render :form
#     end
#   end
# end
#
# Advanced usage in controller: use it for building form, and automatically fetch all permitted params:
#
# def new
#   @command = CreaterOrder.new
# end
#
# def create
#   CreateOrder.call_for(params, user_id: current.user_id, name:).do |command|
#     command.on(:ok) do
#       render :success
#     end
#     command.on(:unauthorized) do
#       redirect_to :index, flash: {error: "You are not authorized"}
#     end
#     command.on(:invalid) do |errors|
#       @command = command
#       render :new
#     end
#   end
# end
#
# View:
#   <%= form_for @command, url: create_order_url do |f| %>
#     <%= f.text_field :name %>
#     <%= f.submit %>
#   <% end %>

# When running in background validations checks are done twice:
# 1. When call_later/call_at is called. If validations fail error is triggered immediately and no job is scheduled.
# 2. When background job starts. If validations fail - job is cancelled.

class BaseCommand
  extend Dry::Initializer

  module Types
    include Dry::Types(default: :params)
  end

  class BaseError < StandardError
    attr_accessor :errors

    def initialize(errors=nil)
      super()
      @errors = errors
    end

    def inspect
      errors&.full_messages&.to_sentence.presence || "#{self.class.name}(no errors added)"
    end
  end

  class AbortCommand < BaseError; end
  class Invalid < BaseError; end
  class Stale < BaseError; end
  class Unauthorized < BaseError; end

  include Wisper::Publisher
  include ActiveSupport::Tryable

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  class << self
    attr_accessor :adapter_klass, :transactional

    def adapter(klass=nil)
      self.adapter_klass = klass if klass
      adapter_klass || detect_adapter
    end

    def detect_adapter
      return if module_parent == Object

      module_parent.name.singularize.safe_constantize
    end

    def transactional?
      true
    end

    def permit_all_params?
      false
    end

    def permit_all_params!
      define_singleton_method(:permit_all_params?) { true }
    end

    def skip_transaction!
      define_singleton_method(:transactional?) { false }
    end

    def attribute(name, type=Types::Any, **options, &)
      # Convert Dry::Types to proper type for dry-initializer
      type = type.optional if type.respond_to?(:optional?)
      options[:optional] = true

      # Define the attribute using dry-initializer
      option(name, type, **options, &)

      # Add setter method for compatibility
      define_method(:"#{name}=") do |value|
        instance_variable_set(:"@#{name}", value)
      end

      # Track attribute names for permitted_attributes
      @attribute_names ||= []
      @attribute_names << name
    end

    def call(attributes=nil, **)
      instance = new(attributes, **)
      yield instance if block_given?
      instance.call
    end

    def call_later(attributes=nil, **kwargs)
      instance = new(attributes, **kwargs)
      yield instance if block_given?

      return instance if instance.preflight_nok?

      # Combine attributes for the job
      combined_attributes = {}
      combined_attributes.merge!(attributes.to_h.symbolize_keys) if attributes.is_a?(Hash)
      combined_attributes.merge!(kwargs)

      DelayedCommandJob.perform_later(self, combined_attributes)
      instance.broadcast_ok
      instance
    end

    def call_at(delay, attributes=nil, **kwargs)
      instance = new(attributes, **kwargs)
      yield instance if block_given?

      return instance if instance.preflight_nok?

      # Combine attributes for the job
      combined_attributes = {}
      combined_attributes.merge!(attributes.to_h.symbolize_keys) if attributes.is_a?(Hash)
      combined_attributes.merge!(kwargs)

      DelayedCommandJob.set(delay).perform_later(self, combined_attributes)
      instance.broadcast_ok
      instance
    end

    def call_for(params, additional_attributes={}, &)
      call(**attributes_from_params(params, additional_attributes), &)
    end

    def attributes_from_params(params, additional_attributes={})
      if permit_all_params?
        params.require(model_name.param_key)
              .permit!
              .to_h
              .merge(additional_attributes)
              .deep_symbolize_keys
      else
        params.require(model_name.param_key)
              .permit(permitted_attributes)
              .to_h
              .merge(additional_attributes)
              .deep_symbolize_keys
      end
    rescue ActionController::ParameterMissing
      additional_attributes
    end

    def permitted_attributes
      attribute_names
    end

    def attribute_names
      @attribute_names || []
    end

    # restore method for bootstrap_forms compatibility
    def try(...)
      ActiveSupport::Tryable.instance_method(:try).bind_call(self, ...)
    end

    def model_name
      ActiveModel::Name.new(adapter || self)
    end

    # Override new to handle both hash arguments and keyword arguments, including mixed usage
    def new(attributes=nil, **kwargs)
      combined_attributes = {}

      # Add hash attributes if provided
      if attributes.is_a?(Hash)
        combined_attributes.merge!(attributes.to_h.symbolize_keys)
      elsif attributes.present?
        raise ArgumentError, "First argument must be a Hash if provided"
      end

      # Add keyword arguments
      combined_attributes.merge!(kwargs)

      # Call parent's new with combined attributes
      super(**combined_attributes)
    end
  end

  delegate :adapter, to: :class

  delegate :transactional?, to: :class

  # sets empty listeners to avoid raising exceptions
  def no_exceptions!
    on(:invalid, :abort, :stale, :unauthorized) {} # rubocop:disable Lint/EmptyBlock
    self
  end

  def call
    if transactional?
      ActiveRecord::Base.transaction do
        call_without_transaction
      end
    else
      call_without_transaction
    end
  rescue AbortCommand
    broadcast(:abort, errors)

    raise AbortCommand.new(errors) unless local_registrations.any?(&it.on.include?(:abort))
  end

  def call_without_transaction
    return if preflight_nok?

    process.tap {
      broadcast_ok
    }
  end

  def preflight_nok?
    return broadcast_unauthorized unless authorized?
    return broadcast_invalid unless valid?
    return broadcast_stale if stale?

    false
  end

  # rubocop:disable Naming/PredicateMethod
  def broadcast_unauthorized
    broadcast(:unauthorized)
    raise Unauthorized unless local_registrations.any?(&it.on.include?(:unauthorized))

    true
  end

  def broadcast_invalid
    broadcast(:invalid, errors)
    raise Invalid.new(errors) unless local_registrations.any?(&it.on.include?(:invalid))

    true
  end

  def broadcast_stale
    broadcast(:stale)
    raise Stale unless local_registrations.any?(&it.on.include?(:stale))

    true
  end
  # rubocop:enable Naming/PredicateMethod

  def abort_command
    raise AbortCommand
  end

  def broadcast_ok
    broadcast(:ok)
  end

  def authorized?
    true
  end

  def stale?
    false
  end

  def persisted?
    false
  end

  def process
    raise "Interface not implemented"
  end

  # Helper method to get all attributes as a hash
  def attributes
    self.class.dry_initializer.attributes(self)
  end

  # Compatibility method for code expecting to_h
  def to_h
    attributes
  end
end
